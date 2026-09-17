import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem(this.name, this.icon, this.imagePath);
  final String name;
  final IconData icon;
  final String imagePath;
}

class StoreItem {
  const StoreItem({required this.name, required this.type, required this.city, this.imagePath});
  final String name;
  final String type;
  final String city;
  final String? imagePath;
}

class ProductItem {
  const ProductItem({required this.name, required this.store, required this.price, required this.imagePath});
  final String name;
  final String store;
  final double price;
  final String imagePath;
}

const categories = [
  CategoryItem('Fashion', Icons.checkroom_rounded, 'assets/images/category-fashion.webp'),
  CategoryItem('Beauty', Icons.spa_rounded, 'assets/images/category-beauty.webp'),
  CategoryItem('Food', Icons.restaurant_rounded, 'assets/images/category-food.webp'),
  CategoryItem('Services', Icons.handyman_rounded, 'assets/images/category-services.webp'),
  CategoryItem('Home', Icons.chair_rounded, 'assets/images/category-home.webp'),
];

const stores = [
  StoreItem(name: 'NOIR', type: 'Streetwear', city: 'Dubai', imagePath: 'assets/images/store-noir.webp'),
  StoreItem(name: 'FORM', type: 'Home & Living', city: 'Abu Dhabi', imagePath: 'assets/images/store-form.webp'),
  StoreItem(name: 'NAYA', type: 'Beauty', city: 'Sharjah'),
  StoreItem(name: 'CRAFT', type: 'Local Makers', city: 'Ajman'),
];

const products = [
  ProductItem(name: 'Everyday Oversized Tee', store: 'NOIR', price: 149, imagePath: 'assets/images/product-tee.webp'),
  ProductItem(name: 'Sculpted Table Lamp', store: 'FORM', price: 320, imagePath: 'assets/images/product-lamp.webp'),
  ProductItem(name: 'Signature Skin Set', store: 'NAYA', price: 210, imagePath: 'assets/images/product-skincare.webp'),
  ProductItem(name: 'Handmade Travel Pouch', store: 'CRAFT', price: 95, imagePath: 'assets/images/product-pouch.webp'),
];
