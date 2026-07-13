import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/local_controller.dart';
import '../models/tag_model.dart';
import '../models/transaction_model.dart';
import 'manage_tags_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool isTab;
  final VoidCallback? onSaveSuccess;
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({
    super.key,
    this.isTab = false,
    this.onSaveSuccess,
    this.transactionToEdit,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final LocalController _controller = LocalController();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  String _selectedType = 'EXPENSE'; // Default is Expense
  TagModel? _selectedTag;
  DateTime _selectedDate = DateTime.now();

  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy - HH:mm น.', 'th_TH');

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _amountController.text = tx.amount % 1 == 0 ? tx.amount.toInt().toString() : tx.amount.toString();
      _noteController.text = tx.note;
      _selectedType = tx.type;
      _selectedDate = tx.timestamp;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Pick Date & Time
  Future<void> _selectDateTime() async {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: const Color(0xFF1E293B), // body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: primaryColor,
                onPrimary: Colors.white,
                onSurface: const Color(0xFF1E293B),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5EFE6);
    final titleColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          widget.transactionToEdit != null ? 'แก้ไขธุรกรรม' : 'เพิ่มธุรกรรมใหม่',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isTab
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _controller.tagsNotifier,
        builder: (context, List<TagModel> allTags, child) {
          // Filter tags matching current transaction type
          final filteredTags = allTags.where((t) => t.type == _selectedType).toList();

          // Reset selected tag if it doesn't match the new filtered tags list
          if (_selectedTag != null && _selectedTag!.type != _selectedType) {
            _selectedTag = null;
          }
          // Default to first tag in the list if none selected
          if (_selectedTag == null && filteredTags.isNotEmpty) {
            if (widget.transactionToEdit != null && widget.transactionToEdit!.type == _selectedType) {
              final editTagId = widget.transactionToEdit!.tagPath.split('/').last;
              _selectedTag = filteredTags.firstWhere(
                (t) => t.id == editTagId,
                orElse: () => filteredTags.first,
              );
            } else {
              _selectedTag = filteredTags.first;
            }
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Type Selector Toggle ---
                  _buildTypeSelector(),
                  const SizedBox(height: 24),

                  // --- Amount Input Field ---
                  _buildSectionLabel('จำนวนเงิน (บาท)'),
                  const SizedBox(height: 8),
                  _buildAmountField(),
                  const SizedBox(height: 24),

                  // --- Tag Selection ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionLabel('แท็ก / หมวดหมู่'),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ManageTagsScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                        label: const Text('จัดการแท็ก'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  filteredTags.isEmpty
                      ? _buildEmptyTagsPlaceholder()
                      : _buildTagDropdown(filteredTags),
                  const SizedBox(height: 24),

                  // --- Note Input Field ---
                  _buildSectionLabel('บันทึกช่วยจำ'),
                  const SizedBox(height: 8),
                  _buildNoteField(),
                  const SizedBox(height: 24),

                  // --- Date Time Picker Row ---
                  _buildSectionLabel('วันที่และเวลา'),
                  const SizedBox(height: 8),
                  _buildDateTimePicker(),
                  const SizedBox(height: 40),

                  // --- Submit Button ---
                  _buildSubmitButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
      ),
    );
  }

  // Custom Toggle for Expense / Income
  Widget _buildTypeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F6);
    final textUnselected = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = 'EXPENSE';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == 'EXPENSE' ? const Color(0xFFEF4444) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'รายจ่าย',
                  style: TextStyle(
                    color: _selectedType == 'EXPENSE' ? Colors.white : textUnselected,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = 'INCOME';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedType == 'INCOME' ? const Color(0xFF10B981) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'รายรับ',
                  style: TextStyle(
                    color: _selectedType == 'INCOME' ? Colors.white : textUnselected,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Amount input text field
  Widget _buildAmountField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final borderSideColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final hintColor = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
    final prefixColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: inputColor,
      ),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: TextStyle(color: hintColor),
        prefixText: '฿ ',
        prefixStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: prefixColor,
        ),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderSideColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'กรุณากรอกจำนวนเงิน';
        }
        final parsed = double.tryParse(value);
        if (parsed == null || parsed <= 0) {
          return 'กรุณากรอกจำนวนเงินมากกว่า 0';
        }
        return null;
      },
    );
  }

  // Tag Selection Dropdown Menu
  Widget _buildTagDropdown(List<TagModel> filteredTags) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dropdownBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final itemTextColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: dropdownBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<TagModel>(
          initialValue: _selectedTag != null && filteredTags.contains(_selectedTag) ? _selectedTag : null,
          hint: const Text('เลือกแท็ก / หมวดหมู่', style: TextStyle(color: Color(0xFF94A3B8))),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          isExpanded: true,
          decoration: const InputDecoration(border: InputBorder.none),
          dropdownColor: dropdownBg,
          items: filteredTags.map((TagModel tag) {
            return DropdownMenuItem<TagModel>(
              value: tag,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: tag.type == 'EXPENSE' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    tag.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: itemTextColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedTag = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'กรุณาเลือกหมวดหมู่แท็ก';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildEmptyTagsPlaceholder() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Text(
            'ไม่พบหมวดหมู่แท็กสำหรับประเภทนี้',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageTagsScreen()),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('เพิ่มแท็กในระบบ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )
        ],
      ),
    );
  }

  // Note helper
  Widget _buildNoteField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final borderSideColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return TextFormField(
      controller: _noteController,
      style: TextStyle(color: inputColor, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'เช่น ค่าน้ำ, ซื้อหนังสือ, ของขวัญปีใหม่...',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderSideColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  // Beautiful clickable date/time picker
  Widget _buildDateTimePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pickerBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderSideColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textValColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);

    return InkWell(
      onTap: _selectDateTime,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: pickerBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderSideColor),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 14),
            Text(
              _dateFormat.format(_selectedDate),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textValColor,
              ),
            ),
            const Spacer(),
            const Icon(Icons.edit_calendar_rounded, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }

  // Submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () async {
          final navigator = Navigator.of(context);
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          if (_formKey.currentState!.validate() && _selectedTag != null) {
            final amount = double.parse(_amountController.text);
            
            try {
              if (widget.transactionToEdit != null) {
                await _controller.updateTransaction(
                  id: widget.transactionToEdit!.id,
                  amount: amount,
                  note: _noteController.text.trim(),
                  tagId: _selectedTag!.id,
                  timestamp: _selectedDate,
                  type: _selectedType,
                );
              } else {
                await _controller.addTransaction(
                  amount: amount,
                  note: _noteController.text.trim(),
                  tagId: _selectedTag!.id,
                  timestamp: _selectedDate,
                  type: _selectedType,
                );
              }

              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(widget.transactionToEdit != null ? 'แก้ไขธุรกรรมเสร็จสิ้น' : 'บันทึกธุรกรรมเสร็จสิ้น'),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );

              if (widget.isTab) {
                _amountController.clear();
                _noteController.clear();
                setState(() {
                  _selectedDate = DateTime.now();
                });
                if (widget.onSaveSuccess != null) {
                  widget.onSaveSuccess!();
                }
              } else {
                navigator.pop();
              }
            } catch (e) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('${widget.transactionToEdit != null ? 'แก้ไข' : 'บันทึก'}ธุรกรรมไม่สำเร็จ: $e'),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: Text(
          widget.transactionToEdit != null ? 'บันทึกการแก้ไข' : 'บันทึกรายการ',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
