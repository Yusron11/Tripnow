import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dahar/models/produk.dart';
import 'package:dahar/screens/maps/posisi_toko.dart';
import 'package:dahar/services/databases/produk_database.dart';
import 'package:flutter/material.dart';
import 'package:dahar/global_styles.dart';
import 'package:dahar/components/back_appbar.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:dahar/screens/maps/networking.dart';
import 'package:provider/provider.dart';

class DetailToko extends StatefulWidget {
  final toko;
  const DetailToko({Key? key, this.toko}) : super(key: key);

  @override
  State<DetailToko> createState() => _DetailTokoState();
}

class _DetailTokoState extends State<DetailToko> {
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late double userLong, userLat;
  double tokoLong = 112.230074;
  double tokoLat = -7.551498;
  double? distance = 0;
  var data;
  String? sellerName;
  // late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    checkGps();
    var tokoRef =
        FirebaseFirestore.instance.doc('user/' + widget.toko.id).get();
    tokoRef.then((val) {
      setState(() {
        sellerName = val.get('nama');
      });
    });
    super.initState();
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457

    long = position.longitude.toString();
    lat = position.latitude.toString();
    double? jarak = await streetDistance(position.latitude, position.longitude,
        widget.toko.lat, widget.toko.long);
    if (mounted) {
      setState(() {
        //refresh UI
        userLong = position.longitude;
        userLat = position.latitude;
        distance = (jarak! / 1000);
      });
    }
  }

  double starightDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<double?> streetDistance(startLat, startLng, endLat, endLng) async {
    NetworkHelper network = NetworkHelper(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
    );

    try {
      // getData() returns a json Decoded data
      data = await network.getData();

      // get distance and print
      return data['features'][0]['properties']['summary']['distance'];
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Produk>>.value(
      initialData: [],
      value: ProdukDatabase(uid: widget.toko.id).produkOnToko,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: BackAppBar(
              title: 'Detail Wisata',
            )),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          color: Colors.white,
          child: ListView(
            shrinkWrap: true,
            children: [
              Column(children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 20),
                  // margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage('${widget.toko.foto}'),
                          fit: BoxFit.cover),
                      shape: BoxShape.circle,
                      color: color1),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${widget.toko.nama}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${widget.toko.alamat}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: color1, width: 2),
                    borderRadius: borderRadius2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          '${distance?.toStringAsFixed(1)} Km',
                          style: TextStyle(color: color1),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: borderRadius2,
                            color: color1,
                            boxShadow: [boxshadow1]),
                        child: TextButton(
                          child: Text('Posisi Wisata',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PosisiToko(
                                        startLat: userLat,
                                        startLng: userLong,
                                        toko: widget.toko,
                                        distance: distance,
                                      )),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
