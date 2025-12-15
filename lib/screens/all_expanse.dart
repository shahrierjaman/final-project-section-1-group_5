import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllExpanse extends StatefulWidget {
  const AllExpanse({super.key});

  @override
  State<AllExpanse> createState() => _AllExpanseState();
}

class _AllExpanseState extends State<AllExpanse> {
  final TextEditingController searchController = TextEditingController();
  String searchText = "";

  String selectedCategory = "All";
  final List<String> categories = [
    "All",
    "Food",
    "Transport",
    "Entertainment",
    "Shopping",
    "Bills",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 10,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "All Expense",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search expense...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Expanse")
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Expense Found"));
                }

                //src +filter code
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;

                  final name = data["name"]?.toString().toLowerCase() ?? "";
                  final category =
                      data["category"]?.toString().toLowerCase() ?? "";

                  final matchesSearch =
                      name.contains(searchText) ||
                      category.contains(searchText);

                  final matchesCategory =
                      selectedCategory == "All" ||
                      data["category"] == selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("No matching expense"));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: filteredDocs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        showEditDialog(doc.id, data);
                      },
                      onLongPress: () {
                        showDeleteDialog(doc.id);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data["name"] ?? "",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            data["category"] ?? "",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "- ${data["date"] ?? ""}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${data["amount"]}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✏️ Edit Dialog
  void showEditDialog(String docId, Map<String, dynamic> data) {
    TextEditingController nameController = TextEditingController(
      text: data['name'],
    );
    TextEditingController amountController = TextEditingController(
      text: data['amount'].toString(),
    );
    TextEditingController categoryController = TextEditingController(
      text: data['category'],
    );
    TextEditingController dateController = TextEditingController(
      text: data['date'],
    );
    TextEditingController descriptionController = TextEditingController(
      text: data['description'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Expense"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Amount"),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: "Date"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection("Expanse")
                    .doc(docId)
                    .update({
                      "name": nameController.text,
                      "amount": double.tryParse(amountController.text) ?? 0,
                      "category": categoryController.text,
                      "date": dateController.text,
                      "description": descriptionController.text,
                    });
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // 🗑 Delete Dialog
  void showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Expense"),
          content: const Text("Are you sure you want to delete this?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("Expanse")
                    .doc(docId)
                    .delete();
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
