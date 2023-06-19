import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripnow/models/auth_user.dart';
import 'package:tripnow/models/wisata.dart';
import 'package:tripnow/screens/detail_wisata.dart';
import 'package:tripnow/screens/maps/networking.dart';
import 'package:tripnow/services/databases/wisata_database.dart';
import 'package:tripnow/services/toko_distance.dart';
import 'package:flutter/material.dart';
import 'package:tripnow/global_styles.dart';
import 'package:tripnow/components/navbar.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripnow/models/produk.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(100), child: DaharAppBar()),
        body: Container(
          // padding: const EdgeInsets.only(right: 30, left: 30),
          color: Colors.white,
          child: ListView(
            children: const [Closest()],
          ),
        ),
        bottomNavigationBar: const NavBar());
  }
}

class DaharAppBar extends StatefulWidget {
  const DaharAppBar({Key? key}) : super(key: key);

  @override
  State<DaharAppBar> createState() => _DaharAppBarState();
}

class _DaharAppBarState extends State<DaharAppBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: color1,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              // Menambahkan widget Expanded
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Tripnow",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// GestureDetector _popularItem(context, String foodImage, String foodTitle,
//     String foodSeller, int foodPrice, double foodRating) {
//   return PopularItem();
// }

class ClosestItem extends StatefulWidget {
  final toko;
  const ClosestItem({Key? key, this.toko}) : super(key: key);

  @override
  State<ClosestItem> createState() => _ClosestItemState();
}

class _ClosestItemState extends State<ClosestItem> {
  double? distance;

  @override
  void initState() {
    getDistance();
    super.initState();
  }

  getDistance() async {
    var tokoDist =
        await TokoDistance(tokoLat: widget.toko.lat, tokoLong: widget.toko.long)
            .checkGps();
    if (mounted) {
      setState(() {
        distance = tokoDist;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.pushNamed(context, '/detail_toko');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailToko(
                    toko: widget.toko,
                  )),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        height: 100,
        decoration: BoxDecoration(
            borderRadius: borderRadius1,
            image: DecorationImage(
                image: NetworkImage(widget.toko.foto), fit: BoxFit.cover)),
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius1,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                child: Text(widget.toko.nama,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
              Text(
                '${distance?.toStringAsFixed(1)} Km',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: color2),
              )
            ]),
          )
        ]),
      ),
    );
  }
}

class Closest extends StatefulWidget {
  const Closest({Key? key}) : super(key: key);

  @override
  State<Closest> createState() => _ClosestState();
}

class _ClosestState extends State<Closest> {
  @override
  Widget build(BuildContext context) {
    AuthUser user = Provider.of<AuthUser>(context);
    return StreamProvider<List<Toko>>.value(
      initialData: [],
      value: TokoDatabase(uid: user.uid).toko,
      child: Container(
        margin: const EdgeInsets.only(left: 25, right: 25, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: const Text(
                'Daftar Wisata Jember',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            ClosestBuilder()
          ],
        ),
      ),
    );
  }
}

class ClosestBuilder extends StatelessWidget {
  const ClosestBuilder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final toko = Provider.of<List<Toko>>(context);
    // log('${toko.first.nama}');
    // toko.forEach((item) {
    //   log('${item.nama}');
    // });
    return Column(
      children: <Widget>[for (var item in toko) ClosestItem(toko: item)],
    );
  }
}
