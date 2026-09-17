import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem(this.name, this.icon);
  final String name;
  final IconData icon;
}

class StoreItem {
  const StoreItem({required this.name, required this.type, required this.city});
  final String name;
  final String type;
  final String city;
}

class ProductItem {
  const ProductItem({required this.name, required this.store, required this.price});
  final String name;
  final String store;
  final double price;
}

const categories = [
  CategoryItem('Fashion', Icons.checkroom_rounded),
  CategoryItem('Beauty', Icons.spa_rounded),
  CategoryItem('Food', Icons.restaurant_rounded),
  CategoryItem('Services', Icons.handyman_rounded),
  CategoryItem('Home', Icons.chair_rounded),
];

const stores = [
  StoreItem(name: 'NOIR', type: 'Streetwear', city: 'Dubai'),
  StoreItem(name: 'FORM', type: 'Home & Living', city: 'Abu Dhabi'),
  StoreItem(name: 'NAYA', type: 'Beauty', city: 'Sharjah'),
  StoreItem(name: 'CRAFT', type: 'Local Makers', city: 'Ajman'),
];

const products = [
  ProductItem(name: 'Everyday Oversized Tee', store: 'NOIR', price: 149),
  ProductItem(name: 'Sculpted Table Lamp', store: 'FORM', price: 320),
  ProductItem(name: 'Signature Skin Set', store: 'NAYA', price: 210),
  ProductItem(name: 'Handmade Travel Pouch', store: 'CRAFT', price: 95),
];
