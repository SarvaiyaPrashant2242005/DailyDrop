// lib/controller/customer_form_bottom_sheet.dart

import 'package:daily_drop/controller/customer_controller.dart';
import 'package:daily_drop/model/Product_model.dart';
import 'package:daily_drop/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/customer_model.dart';
import '../provider/customerProvider.dart';
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

  void _showProductSelectionDialog(List<Product> allProducts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductSearchBottomSheet(
        products: allProducts,
        onProductSelected: (product) {
          _showProductConfigDialog(product);
        },
      ),
    );
  }

  void _showProductConfigDialog(Product product) {
    int quantity = 1;
    DeliveryFrequency frequency = DeliveryFrequency.everyday;
    AlternateDayStart alternateDayStart = AlternateDayStart.today;
    WeekDay weeklyDay = WeekDay.monday;
    int monthlyDate = 1;
    List<WeekDay> customWeekDays = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C8CFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xFF4C8CFF),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${product.defaultPrice.toStringAsFixed(0)} per ${product.unit}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Quantity selector
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (quantity > 1) setSheetState(() => quantity--);
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Icon(Icons.remove, size: 20),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4C8CFF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4C8CFF),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => setSheetState(() => quantity++),
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4C8CFF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.add, size: 20, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Frequency dropdown
                    const Text(
                      'Delivery Frequency',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<DeliveryFrequency>(
                      value: frequency,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: DeliveryFrequency.values.map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f.label),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() {
                            frequency = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Alternate day start option
                    if (frequency == DeliveryFrequency.oneDayOnOneDayOff) ...[
                      const Text(
                        'Start From',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<AlternateDayStart>(
                        value: alternateDayStart,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        items: AlternateDayStart.values.map((start) => DropdownMenuItem(
                          value: start,
                          child: Text(start.label),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => alternateDayStart = val);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Weekly day option
                    if (frequency == DeliveryFrequency.weekly) ...[
                      const Text(
                        'Delivery Day',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<WeekDay>(
                        value: weeklyDay,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        items: WeekDay.values.map((day) => DropdownMenuItem(
                          value: day,
                          child: Text(day.label),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => weeklyDay = val);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Monthly date picker with calendar view
                   // In _showProductConfigDialog method, replace the monthly section with this:

// Monthly date picker as a button that opens popup
if (frequency == DeliveryFrequency.monthly) ...[
  const Text(
    'Delivery Date',
    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
  ),
  const SizedBox(height: 8),
  InkWell(
    onTap: () {
      showDialog(
        context: context,
        builder: (dialogContext) {
          int tempMonthlyDate = monthlyDate;
          return AlertDialog(
            title: const Text(
              'Select Day of Month',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 31,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final isSelected = tempMonthlyDate == day;
                  return InkWell(
                    onTap: () {
                      setSheetState(() => monthlyDate = day);
                      Navigator.pop(dialogContext);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF4C8CFF) 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF4C8CFF)
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Day $monthlyDate of every month',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Icon(
            Icons.calendar_today,
            color: Color(0xFF4C8CFF),
            size: 20,
          ),
        ],
      ),
    ),
  ),
  const SizedBox(height: 16),
],
                    // Custom days selector
                    if (frequency == DeliveryFrequency.custom) ...[
                      const Text(
                        'Select Delivery Days',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: WeekDay.values.map((day) {
                            final isSelected = customWeekDays.contains(day);
                            return FilterChip(
                              label: Text(day.shortLabel),
                              selected: isSelected,
                              onSelected: (selected) {
                                setSheetState(() {
                                  if (selected) {
                                    customWeekDays.add(day);
                                  } else {
                                    customWeekDays.remove(day);
                                  }
                                });
                              },
                              selectedColor: const Color(0xFF4C8CFF).withOpacity(0.2),
                              checkmarkColor: const Color(0xFF4C8CFF),
                              labelStyle: TextStyle(
                                color: isSelected ? const Color(0xFF4C8CFF) : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFF4C8CFF) : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      if (customWeekDays.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Please select at least one day',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                    
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate custom days selection
                          if (frequency == DeliveryFrequency.custom && customWeekDays.isEmpty) {
                            showTopSnackBar(
  context,
  'Please add at least one product',
  isError: true,
);
                            return;
                          }

                          setState(() {
                            final existingIndex = _selectedProducts.indexWhere(
                              (p) => p.productId == product.id
                            );
                            
                            if (existingIndex != -1) {
                              _selectedProducts[existingIndex] = _selectedProducts[existingIndex].copyWith(
                                quantity: quantity,
                                frequency: frequency,
                                alternateDayStart: frequency == DeliveryFrequency.oneDayOnOneDayOff 
                                    ? alternateDayStart 
                                    : null,
                                weeklyDay: frequency == DeliveryFrequency.weekly 
                                    ? weeklyDay 
                                    : null,
                                monthlyDate: frequency == DeliveryFrequency.monthly
                                    ? monthlyDate
                                    : null,
                                customWeekDays: frequency == DeliveryFrequency.custom
                                    ? List.from(customWeekDays)
                                    : null,
                              );
                            } else {
                              _selectedProducts.add(CustomerProduct(
                                productId: product.id,
                                productName: product.name,
                                quantity: quantity,
                                price: product.defaultPrice,
                                unit: product.unit,
                                frequency: frequency,
                                alternateDayStart: frequency == DeliveryFrequency.oneDayOnOneDayOff 
                                    ? alternateDayStart 
                                    : null,
                                weeklyDay: frequency == DeliveryFrequency.weekly 
                                    ? weeklyDay 
                                    : null,
                                monthlyDate: frequency == DeliveryFrequency.monthly
                                    ? monthlyDate
                                    : null,
                                customWeekDays: frequency == DeliveryFrequency.custom
                                    ? List.from(customWeekDays)
                                    : null,
                              ));
                            }
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C8CFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add Product',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  void _removeProduct(int index) {
    setState(() {
      _selectedProducts.removeAt(index);
    });
  }

  void _editSelectedProduct(int index) {
    final productsAsync = ref.read(productsProvider);
    productsAsync.whenData((products) {
      final existing = _selectedProducts[index];
      final product = products.firstWhere((p) => p.id == existing.productId);
      
      int quantity = existing.quantity;
      DeliveryFrequency frequency = existing.frequency;
      AlternateDayStart alternateDayStart = existing.alternateDayStart ?? AlternateDayStart.today;
      WeekDay weeklyDay = existing.weeklyDay ?? WeekDay.monday;
      int monthlyDate = existing.monthlyDate ?? 1;
      List<WeekDay> customWeekDays = existing.customWeekDays != null 
          ? List.from(existing.customWeekDays!) 
          : [];

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4C8CFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF4C8CFF),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  existing.productName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${product.defaultPrice.toStringAsFixed(0)} per ${product.unit}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Quantity selector
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (quantity > 1) setSheetState(() => quantity--);
                                  },
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: const Icon(Icons.remove, size: 20),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4C8CFF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4C8CFF),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setSheetState(() => quantity++),
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4C8CFF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.add, size: 20, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Delivery Frequency',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<DeliveryFrequency>(
                        value: frequency,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        items: DeliveryFrequency.values.map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f.label),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => frequency = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      if (frequency == DeliveryFrequency.oneDayOnOneDayOff) ...[
                        const Text(
                          'Start From',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<AlternateDayStart>(
                          value: alternateDayStart,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          items: AlternateDayStart.values.map((start) => DropdownMenuItem(
                            value: start,
                            child: Text(start.label),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) setSheetState(() => alternateDayStart = val);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      if (frequency == DeliveryFrequency.weekly) ...[
                        const Text(
                          'Delivery Day',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<WeekDay>(
                          value: weeklyDay,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          items: WeekDay.values.map((day) => DropdownMenuItem(
                            value: day,
                            child: Text(day.label),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) setSheetState(() => weeklyDay = val);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Monthly date picker with calendar view
                      if (frequency == DeliveryFrequency.monthly) ...[
                        const Text(
                          'Delivery Date (Day of Month)',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: 31,
                            itemBuilder: (context, index) {
                              final day = index + 1;
                              final isSelected = monthlyDate == day;
                              return InkWell(
                                onTap: () => setSheetState(() => monthlyDate = day),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? const Color(0xFF4C8CFF) 
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected 
                                          ? const Color(0xFF4C8CFF)
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$day',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (frequency == DeliveryFrequency.custom) ...[
                        const Text(
                          'Select Delivery Days',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: WeekDay.values.map((day) {
                              final isSelected = customWeekDays.contains(day);
                              return FilterChip(
                                label: Text(day.shortLabel),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setSheetState(() {
                                    if (selected) {
                                      customWeekDays.add(day);
                                    } else {
                                      customWeekDays.remove(day);
                                    }
                                  });
                                },
                                selectedColor: const Color(0xFF4C8CFF).withOpacity(0.2),
                                checkmarkColor: const Color(0xFF4C8CFF),
                                labelStyle: TextStyle(
                                  color: isSelected ? const Color(0xFF4C8CFF) : Colors.grey.shade700,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isSelected ? const Color(0xFF4C8CFF) : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (customWeekDays.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Please select at least one day',
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                      
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Validate custom days selection
                            if (frequency == DeliveryFrequency.custom && customWeekDays.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select at least one delivery day')),
                              );
                              return;
                            }

                            setState(() {
                              _selectedProducts[index] = existing.copyWith(
                                quantity: quantity,
                                frequency: frequency,
                                alternateDayStart: frequency == DeliveryFrequency.oneDayOnOneDayOff 
                                    ? alternateDayStart 
                                    : null,
                                weeklyDay: frequency == DeliveryFrequency.weekly 
                                    ? weeklyDay 
                                    : null,
                                monthlyDate: frequency == DeliveryFrequency.monthly
                                    ? monthlyDate
                                    : null,
                                customWeekDays: frequency == DeliveryFrequency.custom
                                    ? List.from(customWeekDays)
                                    : null,
                              );
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C8CFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Update Product',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one product')),
        );
        return;
      }

      final customersState = ref.read(customersProvider);
      final name = _nameController.text.trim();

      customersState.whenData((customers) {
        final lowerName = name.toLowerCase();
        final hasDuplicate = customers.any((c) {
          if (isEditMode && c.id == widget.customer!.id) {
            return false;
          }
          return c.name.toLowerCase() == lowerName;
        });

        if (hasDuplicate) {
          showTopSnackBar(
  context,
  'Customer name already exists',
  isError: true,
);
          return;
        }

        final controller = CustomerController(ref);

        if (isEditMode) {
          final updatedCustomer = widget.customer!.copyWith(
            name: name,
            address: _addressController.text,
            phone: _phoneController.text,
            products: _selectedProducts,
          );

          Navigator.of(context).pop();

          controller.updateCustomer(
            customer: updatedCustomer,
            context: context,
          );
        } else {
          Navigator.of(context).pop();

          controller.addCustomer(
            name: name,
            address: _addressController.text,
            phone: _phoneController.text,
            products: _selectedProducts,
            context: context,
          );
        }
      });
    }
  }

  String _getProductScheduleInfo(CustomerProduct product) {
    String schedule = product.frequency.label;
    if (product.frequency == DeliveryFrequency.oneDayOnOneDayOff && product.alternateDayStart != null) {
      schedule += ' (${product.alternateDayStart!.label})';
    } else if (product.frequency == DeliveryFrequency.weekly && product.weeklyDay != null) {
      schedule += ' (${product.weeklyDay!.label})';
    } else if (product.frequency == DeliveryFrequency.monthly && product.monthlyDate != null) {
      schedule += ' (Day ${product.monthlyDate})';
    } else if (product.frequency == DeliveryFrequency.custom && product.customWeekDays != null && product.customWeekDays!.isNotEmpty) {
      schedule += ' (${product.customWeekDays!.map((d) => d.shortLabel).join(', ')})';
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
                Row(
                  children: [
                    if (isEditMode)
                      IconButton(
                        onPressed: () {
                          final controller = CustomerController(ref);
                          controller.deleteCustomer(widget.customer!.id, context);
                          // Navigator.pop(context);
                        },
                        
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Products *',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        productsAsync.when(
                          data: (products) {
                            if (products.isEmpty) return const SizedBox.shrink();
                            return TextButton.icon(
                              onPressed: () => _showProductSelectionDialog(products),
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Add Product'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF4C8CFF),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Selected Products List
                    if (_selectedProducts.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No products added yet',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            productsAsync.when(
                              data: (products) {
                                if (products.isEmpty) {
                                  return Text(
                                    'Add products first to continue',
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                  );
                                }
                                return TextButton(
                                  onPressed: () => _showProductSelectionDialog(products),
                                  child: const Text('Browse Products'),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(_selectedProducts.length, (index) {
                        final product = _selectedProducts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade50,
                                Colors.green.shade50.withOpacity(0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade600,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${product.quantity}x ${product.productName}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            _getProductScheduleInfo(product),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _editSelectedProduct(index),
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: Color(0xFF4C8CFF),
                                    size: 18,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeProduct(index),
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

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

// Product Search Bottom Sheet Widget
class _ProductSearchBottomSheet extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onProductSelected;

  const _ProductSearchBottomSheet({
    required this.products,
    required this.onProductSelected,
  });

  @override
  State<_ProductSearchBottomSheet> createState() => _ProductSearchBottomSheetState();
}

class _ProductSearchBottomSheetState extends State<_ProductSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = widget.products;
      } else {
        _filteredProducts = widget.products
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Product',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.products.length} products available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Products List
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onProductSelected(product);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4C8CFF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Color(0xFF4C8CFF),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${product.defaultPrice.toStringAsFixed(0)} per ${product.unit}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4C8CFF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


void showTopSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  final color = isError ? const Color(0xFFE11D48) : const Color(0xFF16A34A);

  final entry = OverlayEntry(
    builder: (ctx) => Positioned(
      top: MediaQuery.of(ctx).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: const Offset(0, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 3)).then((_) {
    if (entry.mounted) entry.remove();
  });
}