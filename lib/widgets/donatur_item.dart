import 'package:flutter/material.dart';
import 'package:kotak_infak/models/donatur_model.dart';

class DonaturItem extends StatelessWidget {
  final DonaturModel donatur;
  const DonaturItem({
    Key? key,
    required this.donatur,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      // width: MediaQuery.of(context).size.width * 0.8,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(5, 5)),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    // image: DecorationImage(image: NetworkImage(review.image)),
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.5)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donatur.name!,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      donatur.category!,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          letterSpacing: 1,
                          fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            donatur.alamat!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.justify,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                letterSpacing: 1,
                height: 1.6),
          )
        ],
      ),
    );
  }
}
