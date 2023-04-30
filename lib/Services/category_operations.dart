import 'package:ekko/Models/category.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryOperations {
  CategoryOperations._() {}

  static List<Category> getCategories(){
    List<Category> categoryList = [
      Category('Liked Songs', FontAwesomeIcons.solidHeart,'/liked-songs'),
      Category('History', FontAwesomeIcons.clockRotateLeft,'/song-history'),
    ];
    return categoryList;
  }
}