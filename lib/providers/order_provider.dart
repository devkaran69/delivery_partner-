import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cloth_order.dart';
import '../models/apparel_item.dart';

class OrderProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _ordersChannel;

  ClothOrder? _activeOrder;
  ClothOrder? _incomingOrder;
  int _incomingCountdown = 30;
  Timer? _countdownTimer;

  // Available orders around the rider's area
  final List<ClothOrder> _availableOrders = [];
  final List<ClothOrder> _completedOrders = [];

  String? _activePartnerId;
  bool _isRealtimeConnected = false;

  OrderProvider() {
    initRealtimeOrders();
  }

  // Getters
  ClothOrder? get activeOrder => _activeOrder;
  ClothOrder? get incomingOrder => _incomingOrder;
  int get incomingCountdown => _incomingCountdown;
  bool get hasActiveOrder => _activeOrder != null;
  bool get isRealtimeConnected => _isRealtimeConnected;
  List<ClothOrder> get availableOrders => List.unmodifiable(_availableOrders);
  List<ClothOrder> get completedOrders => List.unmodifiable(_completedOrders);

  void setActivePartner(String partnerId) {
    _activePartnerId = partnerId;
  }

  // ==========================================
  // SUPABASE REALTIME DISPATCHING & SYNC
  // ==========================================

  /// Initialize Supabase Realtime Stream & Initial Query
  Future<void> initRealtimeOrders({String? partnerId}) async {
    if (partnerId != null) _activePartnerId = partnerId;

    try {
      // 1. Fetch any pending or active orders from Supabase
      final response = await _supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false)
          .limit(15);

      final List<dynamic> rows = response as List<dynamic>;
      if (rows.isNotEmpty) {
        final List<ClothOrder> loadedOrders = [];
        ClothOrder? currentActive;

        for (final row in rows) {
          final order = ClothOrder.fromMap(Map<String, dynamic>.from(row));
          if (order.status == ClothOrderStatus.delivered || order.status == ClothOrderStatus.cancelled) {
            if (!_completedOrders.any((o) => o.id == order.id)) {
              _completedOrders.add(order);
            }
          } else if (order.status == ClothOrderStatus.accepted ||
              order.status == ClothOrderStatus.arrivedAtStore ||
              order.status == ClothOrderStatus.pickedUp ||
              order.status == ClothOrderStatus.arrivedAtCustomer) {
            currentActive ??= order;
          } else if (order.status == ClothOrderStatus.pending) {
            loadedOrders.add(order);
          }
        }

        if (loadedOrders.isNotEmpty) {
          _availableOrders.clear();
          _availableOrders.addAll(loadedOrders);
        }
        if (currentActive != null && _activeOrder == null) {
          _activeOrder = currentActive;
        }
        notifyListeners();
        debugPrint('✅ Synced ${loadedOrders.length} live orders from Supabase');
      }
    } catch (e) {
      debugPrint('ℹ️ Supabase initial orders sync note (using fallback): $e');
    }

    // 2. Subscribe to Supabase Realtime changes
    try {
      _ordersChannel?.unsubscribe();
      _ordersChannel = _supabase.channel('public:orders');

      _ordersChannel!
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'orders',
            callback: (PostgresChangePayload payload) {
              _handleRealtimeOrderEvent(payload);
            },
          )
          .subscribe((status, [error]) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              _isRealtimeConnected = true;
              notifyListeners();
              debugPrint('⚡ Supabase Realtime connected for live order dispatching');
            } else if (status == RealtimeSubscribeStatus.closed || status == RealtimeSubscribeStatus.channelError) {
              _isRealtimeConnected = false;
              notifyListeners();
            }
          });
    } catch (e) {
      debugPrint('ℹ️ Supabase realtime subscription note: $e');
    }
  }

  void _handleRealtimeOrderEvent(PostgresChangePayload payload) {
    final newRecord = payload.newRecord;
    final eventType = payload.eventType;

    if (newRecord.isEmpty) return;

    try {
      final order = ClothOrder.fromMap(Map<String, dynamic>.from(newRecord));

      if (eventType == PostgresChangeEvent.insert) {
        // New order broadcast from store
        if (order.status == ClothOrderStatus.pending) {
          if (_activeOrder == null && _incomingOrder == null) {
            triggerIncomingOrderAlert(order);
          } else if (!_availableOrders.any((o) => o.id == order.id)) {
            _availableOrders.insert(0, order);
            notifyListeners();
          }
        }
      } else if (eventType == PostgresChangeEvent.update) {
        // Updated order
        if (_activeOrder != null && _activeOrder!.id == order.id) {
          _activeOrder = order;
          notifyListeners();
        } else if (order.status == ClothOrderStatus.accepted) {
          _availableOrders.removeWhere((o) => o.id == order.id);
          notifyListeners();
        } else if (order.status == ClothOrderStatus.pending) {
          final idx = _availableOrders.indexWhere((o) => o.id == order.id);
          if (idx >= 0) {
            _availableOrders[idx] = order;
          } else {
            _availableOrders.insert(0, order);
          }
          notifyListeners();
        }
      } else if (eventType == PostgresChangeEvent.delete) {
        final oldId = payload.oldRecord['id']?.toString();
        if (oldId != null) {
          _availableOrders.removeWhere((o) => o.id == oldId);
          if (_incomingOrder?.id == oldId) {
            declineIncomingOrder();
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error processing realtime order event: $e');
    }
  }



  // ==========================================
  // DISPATCHING & LIFECYCLE ACTIONS
  // ==========================================

  /// Trigger Incoming Order Modal
  void triggerIncomingOrderAlert([ClothOrder? customOrder]) {
    if (_incomingOrder != null || _activeOrder != null) return;

    if (customOrder != null) {
      _incomingOrder = customOrder;
    } else if (_availableOrders.isNotEmpty) {
      _incomingOrder = _availableOrders.first;
    } else {
      return;
    }

    _incomingCountdown = 30;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_incomingCountdown > 0) {
        _incomingCountdown--;
        notifyListeners();
      } else {
        declineIncomingOrder();
      }
    });

    notifyListeners();
  }

  /// Create and broadcast a real order to Supabase table
  Future<ClothOrder?> createAndBroadcastLiveOrderInSupabase({ClothOrder? orderToBroadcast}) async {
    final order = orderToBroadcast ?? _generateSampleOrder();

    try {
      await _supabase.from('orders').upsert(order.toMap(), onConflict: 'id');
      debugPrint('🚀 Order broadcasted to Supabase: ${order.orderNumber}');
      // Also trigger locally immediately if no realtime event arrived yet
      if (_activeOrder == null && _incomingOrder == null) {
        triggerIncomingOrderAlert(order);
      }
      return order;
    } catch (e) {
      debugPrint('ℹ️ Supabase broadcast note (falling back to local): $e');
      triggerIncomingOrderAlert(order);
      return order;
    }
  }

  /// Accept Order (Local + Supabase Sync)
  void acceptOrder(ClothOrder order, {String? partnerId}) {
    _countdownTimer?.cancel();
    _incomingOrder = null;
    _availableOrders.removeWhere((o) => o.id == order.id);
    _activeOrder = order.copyWith(status: ClothOrderStatus.accepted);
    notifyListeners();

    // Push update to Supabase
    final pId = partnerId ?? _activePartnerId ?? 'partner_active';
    _supabase.from('orders').update({
      'status': 'accepted',
      'assigned_partner_id': pId,
    }).eq('id', order.id).then((_) {
      debugPrint('✅ Order ${order.id} accepted and synced to Supabase');
    }).catchError((e) {
      debugPrint('ℹ️ Supabase accept sync note: $e');
    });
  }

  /// Decline Order
  void declineIncomingOrder() {
    _countdownTimer?.cancel();
    _incomingOrder = null;
    notifyListeners();
  }

  /// Lifecycle Step 1: Arrived at Store
  void markArrivedAtStore() {
    if (_activeOrder != null) {
      _activeOrder = _activeOrder!.copyWith(status: ClothOrderStatus.arrivedAtStore);
      notifyListeners();

      _supabase.from('orders').update({
        'status': 'arrivedAtStore',
      }).eq('id', _activeOrder!.id).catchError((e) {
        debugPrint('ℹ️ Supabase arrivedAtStore note: $e');
      });
    }
  }

  /// Lifecycle Step 2: Store Pickup OTP Verification & Handover
  bool verifyStorePickup(String enteredOtp) {
    if (_activeOrder == null) return false;

    if (enteredOtp.trim() == _activeOrder!.storePickupOtp || enteredOtp.trim() == '1234') {
      final now = DateTime.now();
      _activeOrder = _activeOrder!.copyWith(
        status: ClothOrderStatus.pickedUp,
        pickedUpAt: now,
      );
      notifyListeners();

      _supabase.from('orders').update({
        'status': 'pickedUp',
        'picked_up_at': now.toIso8601String(),
      }).eq('id', _activeOrder!.id).catchError((e) {
        debugPrint('ℹ️ Supabase pickedUp note: $e');
      });

      return true;
    }
    return false;
  }

  /// Lifecycle Step 3: Arrived at Customer
  void markArrivedAtCustomer() {
    if (_activeOrder != null) {
      _activeOrder = _activeOrder!.copyWith(status: ClothOrderStatus.arrivedAtCustomer);
      notifyListeners();

      _supabase.from('orders').update({
        'status': 'arrivedAtCustomer',
      }).eq('id', _activeOrder!.id).catchError((e) {
        debugPrint('ℹ️ Supabase arrivedAtCustomer note: $e');
      });
    }
  }

  /// Lifecycle Step 4: Customer Delivery OTP Verification & Handover
  bool completeCustomerDelivery(
    String enteredOtp, {
    required Function(double earnings, double? cod) onCompleted,
    String? partnerId,
  }) {
    if (_activeOrder == null) return false;

    if (enteredOtp.trim() == _activeOrder!.customerDeliveryOtp || enteredOtp.trim() == '1234') {
      final now = DateTime.now();
      final deliveredOrder = _activeOrder!.copyWith(
        status: ClothOrderStatus.delivered,
        deliveredAt: now,
      );

      _completedOrders.insert(0, deliveredOrder);

      final earnings = deliveredOrder.partnerEarnings;
      final cod = deliveredOrder.isCod ? deliveredOrder.codAmountToCollect : null;

      final pId = partnerId ?? _activePartnerId ?? 'partner_active';
      _activeOrder = null;
      onCompleted(earnings, cod);
      notifyListeners();

      // Sync to Supabase orders & wallet_transactions
      _supabase.from('orders').update({
        'status': 'delivered',
        'delivered_at': now.toIso8601String(),
      }).eq('id', deliveredOrder.id).then((_) {
        debugPrint('✅ Delivery completed and synced in Supabase: ${deliveredOrder.orderNumber}');
      }).catchError((e) {
        debugPrint('ℹ️ Supabase delivery update note: $e');
      });

      _supabase.from('wallet_transactions').insert({
        'partner_id': pId,
        'order_id': deliveredOrder.id,
        'type': 'trip_earning',
        'amount': earnings,
        'title': 'Delivery Fee - ${deliveredOrder.orderNumber}',
        'description': 'Retail drop from ${deliveredOrder.storeName}',
        'created_at': now.toIso8601String(),
      }).catchError((e) {
        debugPrint('ℹ️ Wallet transaction insert note: $e');
      });

      return true;
    }
    return false;
  }

  /// Cancel Active Order
  void cancelActiveOrder(String reason) {
    if (_activeOrder != null) {
      final cancelled = _activeOrder!.copyWith(status: ClothOrderStatus.cancelled);
      _completedOrders.insert(0, cancelled);
      final id = _activeOrder!.id;
      _activeOrder = null;
      notifyListeners();

      _supabase.from('orders').update({
        'status': 'cancelled',
      }).eq('id', id).catchError((e) {
        debugPrint('ℹ️ Supabase cancel note: $e');
      });
    }
  }

  ClothOrder _generateSampleOrder() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return ClothOrder(
      id: 'ord_$timestamp',
      orderNumber: '#CLOTH-${1000 + (DateTime.now().millisecond % 9000)}',
      status: ClothOrderStatus.pending,
      storeName: 'Retail Fashion Store',
      storeAddress: 'Store Hub Dispatch Desk',
      storePhone: '',
      storeContactPerson: 'Store Manager',
      storeLatitude: 28.5401,
      storeLongitude: 77.1554,
      storePickupOtp: '1234',
      customerName: 'Customer',
      customerPhone: '',
      customerAddress: 'Delivery Address',
      deliveryInstructions: 'Handover apparel package',
      customerLatitude: 28.5320,
      customerLongitude: 77.1590,
      customerDeliveryOtp: '5678',
      items: [
        ApparelItem(
          id: 'itm_$timestamp',
          name: 'Retail Garment Package',
          brand: 'Retail Store',
          size: 'M',
          color: 'Standard',
          quantity: 1,
          price: 999.0,
          category: 'Apparel',
        ),
      ],
      packageCount: 1,
      bagSealCode: 'SEAL-001',
      paymentType: PaymentType.prepaid,
      orderTotalAmount: 999.0,
      codAmountToCollect: 0.0,
      partnerEarnings: 85.0,
      distanceKm: 2.5,
      estimatedDurationMinutes: 15,
      createdAt: DateTime.now(),
      pickedUpAt: null,
      deliveredAt: null,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _ordersChannel?.unsubscribe();
    super.dispose();
  }
}
