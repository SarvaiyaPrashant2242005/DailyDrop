// lib/controller/customer_form_bottom_sheet.dart

import 'package:daily_drop/controller/customer_controller.dart';
import 'package:daily_drop/model/Product_model.dart';
import 'package:daily_drop/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/customer_model.dart';
import '../provider/productProvider.dart';

class CustomerFormBottomSheet extends ConsumerStatefulWidget {
  final Customer? customer;

  const CustomerFormBottomSheet({super.key, this.customer});

  @override
  ConsumerState<CustomerFormBottomSheet> createState() => _CustomerFormBottomSheetState();
}

class _CustomerFormBottomSheetState extends ConsumerState<CustomerFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  
  late List<CustomerProduct> _selectedProducts;
  
  bool get isEditMode => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _selectedProducts = widget.customer != null 
        ? List.from(widget.customer!.products)
        : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _addProduct(Product product, int quantity, DeliveryFrequency frequency, 
      {AlternateDayStart? alternateDayStart, WeekDay? weeklyDay}) {
    setState(() {
      final existingIndex = _selectedProducts.indexWhere((p) => p.productId == product.id);
      if (existingIndex != -1) {
        final existing = _selectedProducts[existingIndex];
        _selectedProducts[existingIndex] = existing.copyWith(
          quantity: quantity,
          frequency: frequency,
          alternateDayStart: alternateDayStart,
          weeklyDay: weeklyDay,
        );
      } else {
        _selectedProducts.add(CustomerProduct(
          productId: product.id,
          productName: product.name,
          quantity: quantity,
          price: product.defaultPrice,
          unit: product.unit,
          frequency: frequency,
          alternateDayStart: alternateDayStart,
          weeklyDay: weeklyDay,
        ));
      }
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _selectedProducts.removeAt(index);
    });
  }

  void _editSelectedProduct(int index) {
    final existing = _selectedProducts[index];
    int q = existing.quantity;
    DeliveryFrequency freq = existing.frequency;
    AlternateDayStart? altStart = existing.alternateDayStart;
    WeekDay? weekDay = existing.weeklyDay;

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(existing.productName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Quantity selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quantity:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (q > 1) setSheetState(() => q--);
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('$q', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              onPressed: () => setSheetState(() => q++),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Delivery Frequency:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<DeliveryFrequency>(
                      value: freq,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: DeliveryFrequency.values.map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f.label),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() {
                            freq = val;
                            // Reset schedule options when frequency changes
                            if (freq == DeliveryFrequency.oneDayOnOneDayOff) {
                              altStart = altStart ?? AlternateDayStart.today;
                              weekDay = null;
                            } else if (freq == DeliveryFrequency.weekly) {
                              weekDay = weekDay ?? WeekDay.monday;
                              altStart = null;
                            } else {
                              altStart = null;
                              weekDay = null;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Show alternate day start option
                    if (freq == DeliveryFrequency.oneDayOnOneDayOff) ...[
                      const Text('Start From:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<AlternateDayStart>(
                        value: altStart ?? AlternateDayStart.today,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: AlternateDayStart.values.map((start) => DropdownMenuItem(
                          value: start,
                          child: Text(start.label),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => altStart = val);
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Show weekly day option
                    if (freq == DeliveryFrequency.weekly) ...[
                      const Text('Delivery Day:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<WeekDay>(
                        value: weekDay ?? WeekDay.monday,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: WeekDay.values.map((day) => DropdownMenuItem(
                          value: day,
                          child: Text(day.label),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => weekDay = val);
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedProducts[index] = existing.copyWith(
                              quantity: q,
                              frequency: freq,
                              alternateDayStart: altStart,
                              weeklyDay: weekDay,
                            );
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C8CFF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Save', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one product')),
        );
        return;
      }

      final controller = CustomerController(ref);
      
      if (isEditMode) {
        final updatedCustomer = widget.customer!.copyWith(
          name: _nameController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          products: _selectedProducts,
        );
        controller.updateCustomer(
          customer: updatedCustomer,
          context: context,
        );
      } else {
        controller.addCustomer(
          name: _nameController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          products: _selectedProducts,
          context: context,
        );
      }
    }
  }

  String _getProductScheduleInfo(CustomerProduct product) {
    String schedule = product.frequency.label;
    if (product.frequency == DeliveryFrequency.oneDayOnOneDayOff && product.alternateDayStart != null) {
      schedule += ' (${product.alternateDayStart!.label})';
    } else if (product.frequency == DeliveryFrequency.weekly && product.weeklyDay != null) {
      schedule += ' (${product.weeklyDay!.label})';
    }
    return schedule;
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditMode ? 'Edit Customer' : 'Add Customer',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    const Text('Name *', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Customer name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter customer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Address Field
                    const Text('Address *', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Delivery address',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Phone Field
                    const Text('Phone', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '+91 98765 43210',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Products Section
                    const Text('Products *', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    const SizedBox(height: 12),

                    // Selected Products List
                    if (_selectedProducts.isNotEmpty)
                      ...List.generate(_selectedProducts.length, (index) {
                        final product = _selectedProducts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${product.quantity}x ${product.productName}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _getProductScheduleInfo(product),
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _editSelectedProduct(index),
                                    icon: const Icon(Icons.edit, color: Color(0xFF4C8CFF)),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeProduct(index),
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 12),

                    // Available Products
                    productsAsync.when(
                      data: (products) {
                        if (products.isEmpty) {
                          return Text(
                            isEditMode 
                                ? 'No products available.' 
                                : 'No products available. Add products first.'
                          );
                        }

                        return Column(
                          children: products.map((product) {
                            return _ProductSelectionTile(
                              product: product,
                              onAdd: (quantity, frequency, alternateDayStart, weeklyDay) => 
                                  _addProduct(product, quantity, frequency, 
                                      alternateDayStart: alternateDayStart, weeklyDay: weeklyDay),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: const LoadingOverlay()),
                      error: (_, __) => const Text('Error loading products'),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Submit Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C8CFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEditMode ? 'Update Customer' : 'Add Customer',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Product Selection Tile Widget
class _ProductSelectionTile extends StatefulWidget {
  final Product product;
  final Function(int quantity, DeliveryFrequency frequency, AlternateDayStart? alternateDayStart, WeekDay? weeklyDay) onAdd;

  const _ProductSelectionTile({
    required this.product,
    required this.onAdd,
  });

  @override
  State<_ProductSelectionTile> createState() => _ProductSelectionTileState();
}

class _ProductSelectionTileState extends State<_ProductSelectionTile> {
  int _quantity = 1;
  DeliveryFrequency _frequency = DeliveryFrequency.everyday;
  AlternateDayStart _alternateDayStart = AlternateDayStart.today;
  WeekDay _weeklyDay = WeekDay.monday;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('₹${widget.product.defaultPrice.toStringAsFixed(0)} each'),
            trailing: _isExpanded
                ? const Icon(Icons.expand_less)
                : const Icon(Icons.expand_more),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantity:', style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () => setState(() => _quantity++),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Frequency Dropdown
                  const Text('Delivery Frequency:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<DeliveryFrequency>(
                    value: _frequency,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: DeliveryFrequency.values.map((freq) {
                      return DropdownMenuItem(
                        value: freq,
                        child: Text(freq.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _frequency = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  // Show alternate day start option
                  if (_frequency == DeliveryFrequency.oneDayOnOneDayOff) ...[
                    const Text('Start From:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<AlternateDayStart>(
                      value: _alternateDayStart,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: AlternateDayStart.values.map((start) {
                        return DropdownMenuItem(
                          value: start,
                          child: Text(start.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _alternateDayStart = value);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Show weekly day option
                  if (_frequency == DeliveryFrequency.weekly) ...[
                    const Text('Delivery Day:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<WeekDay>(
                      value: _weeklyDay,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: WeekDay.values.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(day.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _weeklyDay = value);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onAdd(
                          _quantity,
                          _frequency,
                          _frequency == DeliveryFrequency.oneDayOnOneDayOff ? _alternateDayStart : null,
                          _frequency == DeliveryFrequency.weekly ? _weeklyDay : null,
                        );
                        setState(() {
                          _isExpanded = false;
                          _quantity = 1;
                          _frequency = DeliveryFrequency.everyday;
                          _alternateDayStart = AlternateDayStart.today;
                          _weeklyDay = WeekDay.monday;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C8CFF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}