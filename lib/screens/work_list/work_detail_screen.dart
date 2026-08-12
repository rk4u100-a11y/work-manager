import 'package:flutter/material.dart';

import 'work_data.dart';

class WorkDetailScreen extends StatefulWidget {
  final String workName;

  const WorkDetailScreen({
    super.key,
    required this.workName,
  });

  @override
  State<WorkDetailScreen> createState() =>
      _WorkDetailScreenState();
}

class _WorkDetailScreenState
    extends State<WorkDetailScreen> {
  late TextEditingController nameController;

  final TextEditingController loaController =
      TextEditingController();

  final TextEditingController currencyController =
      TextEditingController();

  final TextEditingController billStatusController =
      TextEditingController();

  // User added fields
  final List<Map<String, dynamic>> additionalDetails = [];

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.workName);
  }

  @override
  void dispose() {
    nameController.dispose();
    loaController.dispose();
    currencyController.dispose();
    billStatusController.dispose();

    for (final detail in additionalDetails) {
      final controller =
          detail['controller'] as TextEditingController;

      controller.dispose();
    }

    super.dispose();
  }

  // ==================================================
  // ADD NEW ITEM
  // ==================================================

  void _addNewDetail() {
    final TextEditingController titleController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Item'),

          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Name of Item',
              hintText: 'Example: Contractor',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                titleController.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                final String title =
                    titleController.text.trim();

                if (title.isEmpty) {
                  return;
                }

                setState(() {
                  additionalDetails.add({
                    'title': title,
                    'controller':
                        TextEditingController(),
                  });
                });

                titleController.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ==================================================
  // EDIT NEW ITEM
  // ==================================================

  void _editAdditionalDetail(int index) {
    final Map<String, dynamic> detail =
        additionalDetails[index];

    final TextEditingController titleController =
        TextEditingController(
      text: detail['title'] as String,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Item'),

          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Name of Item',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                titleController.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                final String newTitle =
                    titleController.text.trim();

                if (newTitle.isEmpty) {
                  return;
                }

                setState(() {
                  detail['title'] = newTitle;
                });

                titleController.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ==================================================
  // DELETE NEW ITEM
  // ==================================================

  void _deleteAdditionalDetail(int index) {
    final TextEditingController controller =
        additionalDetails[index]['controller']
            as TextEditingController;

    controller.dispose();

    setState(() {
      additionalDetails.removeAt(index);
    });
  }

  // ==================================================
  // EDIT STANDARD FIELD
  // ==================================================

  void _editStandardField({
    required String fieldName,
    required TextEditingController controller,
  }) {
    final TextEditingController editController =
        TextEditingController(
      text: fieldName,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Item'),

          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Name of Item',
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                editController.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                final String newName =
                    editController.text.trim();

                if (newName.isEmpty) {
                  return;
                }

                // The standard field name is kept
                // as part of the current structure.
                // Its value remains editable
                // directly in the text field.

                editController.dispose();
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      '$fieldName is a standard item.',
                    ),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ==================================================
  // DELETE STANDARD FIELD
  // ==================================================

  void _deleteStandardField(
    String fieldName,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$fieldName is a standard item and cannot be deleted.',
        ),
      ),
    );
  }

  // ==================================================
  // STANDARD FIELD MENU
  // ==================================================

  Widget _standardFieldMenu({
    required String fieldName,
    required TextEditingController controller,
  }) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
      ),

      tooltip: 'More options',

      onSelected: (String value) {
        if (value == 'edit') {
          _editStandardField(
            fieldName: fieldName,
            controller: controller,
          );
        }

        if (value == 'delete') {
          _deleteStandardField(
            fieldName,
          );
        }
      },

      itemBuilder: (BuildContext context) {
        return const [
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text('Edit'),
              ],
            ),
          ),

          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text('Delete'),
              ],
            ),
          ),
        ];
      },
    );
  }

  // ==================================================
  // NEW FIELD MENU
  // ==================================================

  Widget _additionalFieldMenu(
    int index,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
      ),

      tooltip: 'More options',

      onSelected: (String value) {
        if (value == 'edit') {
          _editAdditionalDetail(index);
        }

        if (value == 'delete') {
          _deleteAdditionalDetail(index);
        }
      },

      itemBuilder: (BuildContext context) {
        return const [
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text('Edit'),
              ],
            ),
          ),

          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text('Delete'),
              ],
            ),
          ),
        ];
      },
    );
  }

  // ==================================================
  // STANDARD FIELD
  // ==================================================

  Widget _buildStandardField({
    required String fieldName,
    required TextEditingController controller,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,

              decoration: InputDecoration(
                labelText: fieldName,
                hintText: hint,
                border:
                    const OutlineInputBorder(),
              ),
            ),
          ),

          _standardFieldMenu(
            fieldName: fieldName,
            controller: controller,
          ),
        ],
      ),
    );
  }

  // ==================================================
  // NEW FIELD
  // ==================================================

  Widget _buildAdditionalField(
    int index,
  ) {
    final Map<String, dynamic> detail =
        additionalDetails[index];

    final String title =
        detail['title'] as String;

    final TextEditingController controller =
        detail['controller']
            as TextEditingController;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,

              decoration: InputDecoration(
                labelText: title,
                hintText: 'Enter $title',
                border:
                    const OutlineInputBorder(),
              ),
            ),
          ),

          _additionalFieldMenu(index),
        ],
      ),
    );
  }

  // ==================================================
  // SAVE WORK
  // ==================================================

  void _saveWork() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the Name of Work.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Work details saved.',
        ),
      ),
    );
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Work Details',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            // ==================================================
            // NAME OF WORK
            // ==================================================

            _buildStandardField(
              fieldName: 'Name of Work',
              controller: nameController,
            ),

            // ==================================================
            // LOA
            // ==================================================

            _buildStandardField(
              fieldName: 'LOA',
              controller: loaController,
              hint: 'Enter LOA',
            ),

            // ==================================================
            // CURRENCY
            // ==================================================

            _buildStandardField(
              fieldName: 'Currency',
              controller: currencyController,
              hint: 'Enter Currency',
            ),

            // ==================================================
            // BILL STATUS
            // ==================================================

            _buildStandardField(
              fieldName: 'Bill Status',
              controller: billStatusController,
              hint: 'Enter Bill Status',
            ),

            // ==================================================
            // ADDITIONAL FIELDS
            // ==================================================

            ...List.generate(
              additionalDetails.length,
              (index) {
                return _buildAdditionalField(
                  index,
                );
              },
            ),

            // ==================================================
            // ADD NEW
            // ==================================================

            OutlinedButton.icon(
              onPressed: _addNewDetail,

              icon: const Icon(
                Icons.add,
              ),

              label: const Text(
                'Add New',
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // SAVE
            // ==================================================

            SizedBox(
              height: 50,

              child: ElevatedButton.icon(
                onPressed: _saveWork,

                icon: const Icon(
                  Icons.save,
                ),

                label: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}