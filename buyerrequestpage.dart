import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class BuyerRequestsPage extends StatefulWidget {
  final String cropName;
  final String cropId; // ye SellCropFormPage se milega

  const BuyerRequestsPage({super.key, required this.cropName, required this.cropId});

  @override
  State<BuyerRequestsPage> createState() => _BuyerRequestsPageState();
}

class _BuyerRequestsPageState extends State<BuyerRequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nearby Buyers")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("buyers")
            .where("cropName", isEqualTo: widget.cropName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final buyers = snapshot.data!.docs;

          if (buyers.isEmpty) return const Center(child: Text("No buyers available yet."));

          return ListView.builder(
            itemCount: buyers.length,
            itemBuilder: (context, index) {
              final buyer = buyers[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(buyer['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "Offered: ₹${buyer['offeredPrice']}\n"
                    "Distance: ${buyer['distance']} km | Rating: ${buyer['rating']}⭐",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _acceptDeal(buyer.id, buyer['offeredPrice']),
                        tooltip: "Accept Deal",
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _negotiateDeal(buyer.id, buyer['offeredPrice']),
                        tooltip: "Negotiate Price",
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat, color: Colors.blue),
                        onPressed: () => _openChat(buyer.id, buyer['name']),
                        tooltip: "Chat",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Accept Deal
  void _acceptDeal(String buyerId, int price) {
    FirebaseFirestore.instance.collection("deals").add({
      "cropId": widget.cropId,
      "buyerId": buyerId,
      "status": "accepted",
      "price": price,
      "timestamp": FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Deal accepted!")),
    );
  }

  // Negotiate Deal
  void _negotiateDeal(String buyerId, int currentPrice) {
    final TextEditingController priceController =
        TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Negotiate Price"),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Enter new price"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection("deals").add({
                "cropId": widget.cropId,
                "buyerId": buyerId,
                "status": "negotiation",
                "price": int.parse(priceController.text),
                "timestamp": FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Negotiation sent!")),
              );
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  // Open Chat Page
  void _openChat(String buyerId, String buyerName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(buyerId: buyerId, buyerName: buyerName),
      ),
    );
  }
}
