import 'package:flutter/material.dart';
import '../controllers/local_controller.dart';
import '../models/tag_model.dart';

class ManageTagsScreen extends StatefulWidget {
  const ManageTagsScreen({super.key});

  @override
  State<ManageTagsScreen> createState() => _ManageTagsScreenState();
}

class _ManageTagsScreenState extends State<ManageTagsScreen> {
  final LocalController _controller = LocalController();
  final _addTagKey = GlobalKey<FormState>();
  final TextEditingController _newTagController = TextEditingController();
  String _newTagType = 'EXPENSE';

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  // Show Bottom Sheet to Add Tag
  // Show Bottom Sheet to Add Tag
  void _showAddTagSheet() {
    final isDarkSheet = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkSheet ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textTitle = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
            final toggleBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF2F6);
            final toggleTextUnselected = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
            final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
            final inputColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
            final borderSideColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: _addTagKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'เพิ่มแท็กใหม่',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textTitle,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // --- Type Toggle (Expense / Income) ---
                    const Text(
                      'ประเภทแท็ก',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: toggleBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  _newTagType = 'EXPENSE';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _newTagType == 'EXPENSE' ? const Color(0xFFEF4444) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'รายจ่าย',
                                  style: TextStyle(
                                    color: _newTagType == 'EXPENSE' ? Colors.white : toggleTextUnselected,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  _newTagType = 'INCOME';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _newTagType == 'INCOME' ? const Color(0xFF10B981) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'รายรับ',
                                  style: TextStyle(
                                    color: _newTagType == 'INCOME' ? Colors.white : toggleTextUnselected,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Tag Name Input ---
                    const Text(
                      'ชื่อแท็ก',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newTagController,
                      autofocus: true,
                      style: TextStyle(color: inputColor, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'เช่น ค่ารักษาพยาบาล, ค่าเที่ยว, ขายของออนไลน์...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: inputBg,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderSideColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณาระบุชื่อแท็ก';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // --- Submit Button ---
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_addTagKey.currentState!.validate()) {
                            try {
                              await _controller.addTag(_newTagController.text.trim(), _newTagType);
                              _newTagController.clear();
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('เพิ่มแท็กใหม่สำเร็จ'),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('เพิ่มแท็กไม่สำเร็จ: $e'),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('ตกลง', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5EFE6);
    final titleColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final unselectedTabColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: scaffoldBgColor,
        appBar: AppBar(
          title: Text(
            'จัดการแท็กทั้งหมด',
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: unselectedTabColor,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: const [
              Tab(text: 'แท็กรายจ่าย'),
              Tab(text: 'แท็กรายรับ'),
            ],
          ),
        ),
        body: ValueListenableBuilder(
          valueListenable: _controller.tagsNotifier,
          builder: (context, List<TagModel> tags, child) {
            final expenseTags = tags.where((t) => t.type == 'EXPENSE').toList();
            final incomeTags = tags.where((t) => t.type == 'INCOME').toList();

            return TabBarView(
              children: [
                _buildTagListView(expenseTags, const Color(0xFFEF4444)),
                _buildTagListView(incomeTags, const Color(0xFF10B981)),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddTagSheet,
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          label: const Text(
            'เพิ่มแท็กใหม่',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagListView(List<TagModel> tagsList, Color indicatorColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textUnselected = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final itemTextColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);

    if (tagsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.label_off_rounded, size: 64, color: textUnselected),
            const SizedBox(height: 12),
            Text(
              'ไม่มีแท็กในหมวดหมู่นี้',
              style: TextStyle(color: textUnselected, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      itemCount: tagsList.length,
      itemBuilder: (context, index) {
        final tag = tagsList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.01),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                tag.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: itemTextColor,
                ),
              ),
              const Spacer(),
              Text(
                'ID: ${tag.id}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _confirmDeleteTag(tag),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteTag(TagModel tag) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final contentColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'ยืนยันการลบแท็ก',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          content: Text(
            'คุณแน่ใจหรือไม่ว่าต้องการลบแท็ก "${tag.label}"?\n* หมายเหตุ: รายการธุรกรรมที่มีอยู่จะไม่มีแท็กนี้อีกต่อไป แต่ข้อมูลจำนวนเงินจะยังอยู่',
            style: TextStyle(
              color: contentColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'ยกเลิก',
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'ลบแท็ก',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        await _controller.deleteTag(tag.id);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('ลบแท็ก "${tag.label}" เรียบร้อยแล้ว'),
            backgroundColor: const Color(0xFF334155),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('ลบแท็กไม่สำเร็จ: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
