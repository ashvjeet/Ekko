import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<CarouselSlider> getCarousel() async {

  final List<String> imageUrls = [];
   QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('songs').get();
    snapshot.docs.forEach((doc) {
      imageUrls.add(doc.get('song_art_url'));
    });

  return CarouselSlider(
    items: imageUrls.map((imageUrl) {
      return Opacity(opacity: 0.9, child: Image.network(imageUrl, fit: BoxFit.cover, width: 175));}).toList(),
      options: CarouselOptions(
      autoPlay: true,
      enlargeCenterPage: false,
      viewportFraction: 0.466,
      enableInfiniteScroll: true,
      autoPlayInterval: Duration(seconds: 5),
      autoPlayAnimationDuration: Duration(milliseconds: 2000),
      pauseAutoPlayOnTouch: true,
      scrollDirection: Axis.horizontal,
      
    ),
  );  
}
