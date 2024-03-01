import 'package:flutter/material.dart';
import 'package:kotak_infak/models/user_model.dart';

class PetugasItem extends StatelessWidget {
  final UserModel petugas;
  const PetugasItem({
    Key? key,
    required this.petugas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      width: (MediaQuery.of(context).size.width / 2) - 25,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(5, 5))
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
                // image: DecorationImage(image: NetworkImage(doctor.image)),
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          Text('${petugas.name}',
              style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 1,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(petugas.email!,
              style: const TextStyle(
                  letterSpacing: 1,
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.25),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.yellow,
                  size: 20,
                ),
                SizedBox(width: 5),
                //totla transaksi
                Text(
                  '1233',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
