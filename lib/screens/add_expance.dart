import 'package:flutter/material.dart';
import '../services/database.dart';
import 'package:random_string/random_string.dart';

class AddExpance extends StatefulWidget {
  @override
  _AddExpanceState createState() => _AddExpanceState();
}

class _AddExpanceState extends State<AddExpance> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController createdAController = TextEditingController();

  String? selectedCategory;

  final List<String> categories = [
    "Food",
    "Transport",
    "Entertainment",
    "Shopping",
    "Bills",
    "Other",
  ];

  Future<void> pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = "${picked.day}-${picked.month}-${picked.year}";
    }
  }

  InputDecoration simpleInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color.fromARGB(82, 231, 225, 233),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Future<void> saveExpanse() async {
    //simple validation
    if (nameController.text.isEmpty ||
        amountController.text.isEmpty ||
        dateController.text.isEmpty ||
        selectedCategory == null ||
        descriptionController.text.isEmpty ||
        createdAController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    // Generate unique ID
    String id = randomAlphaNumeric(10);

    // Create a map to store in Firestore
    Map<String, dynamic> expInfoMap = {
      "name": nameController.text,
      "amount": amountController.text,
      "date": dateController.text,
      "category": selectedCategory,
      "description": descriptionController.text,
      "createdAt": createdAController.text,
      "id": id,
    };

    try {
      await DatabaseMethods().addExpDetails(expInfoMap, id);

      // Success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Expanse Added Successfully")));

      // Clear fields after success
      nameController.clear();
      amountController.clear();
      dateController.clear();
      descriptionController.clear();
      createdAController.clear();
      setState(() => selectedCategory = null);
    } catch (e) {
      // Error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 10,

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add New Expense",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            Text(
              "Fill the details below",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),

      // BODY
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                "Expense Name",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 5),
              TextField(
                controller: nameController,
                decoration: simpleInputDecoration("Enter Expense name"),
              ),
              SizedBox(height: 18),

              // Amount
              Text("Amount", style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 5),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: simpleInputDecoration("Enter amount"),
              ),
              SizedBox(height: 18),

              // Date
              Text("Date", style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 5),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: simpleInputDecoration(
                  "Pick a date",
                ).copyWith(suffixIcon: Icon(Icons.calendar_today)),
                onTap: () => pickDate(dateController),
              ),
              SizedBox(height: 18),

              // Category
              Text("Category", style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black45),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: SizedBox(),
                  hint: Text("Select Category"),
                  value: selectedCategory,
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                ),
              ),
              SizedBox(height: 18),

              // Description
              Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 5),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: simpleInputDecoration("Write description"),
              ),
              SizedBox(height: 18),

              // Created At
              Text("Created At", style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 5),
              TextField(
                controller: createdAController,
                readOnly: true,
                decoration: simpleInputDecoration(
                  "Pick created date",
                ).copyWith(suffixIcon: Icon(Icons.calendar_today)),
                onTap: () => pickDate(createdAController),
              ),
              SizedBox(height: 25),

              // Submit Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                  ),
                  child: Text("Submit", style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    saveExpanse();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
