import 'package:flutter/material.dart';

class ExplorePhoto {
  final String id;
  String name;
  final String imageUrl;
  final DateTime dateAdded;
  int likes;
  int commentsCount;
  bool isSelected;

  String caption;
  List<String> tags;
  final String username;
  final String userAvatar;
  final bool isOwner;

  ExplorePhoto({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.dateAdded,
    required this.likes,
    this.commentsCount = 0,
    this.isSelected = false,
    required this.caption,
    required this.tags,
    required this.username,
    required this.userAvatar,
    this.isOwner = false,
  });
}

class ExploreAlbum {
  final String id;
  final String title;
  final List<String> imageUrl;
  final List<String> imageUrls;
  final int photoCount;

  ExploreAlbum({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.photoCount,
  }) : imageUrl = imageUrls;
}

List<ExplorePhoto> initialMockPhotos = [
  ExplorePhoto(
    id: '1',
    name: 'Rose',
    imageUrl: 'assets/images/rose.jpg',
    dateAdded: DateTime.now().subtract(const Duration(days: 2)),
    likes: 120,
    commentsCount: 5,
    username: 'mahsa_flower',
    userAvatar: 'assets/images/rose.jpg',
    isOwner: true,
    caption: 'A beautiful rose from my garden! #nature',
    tags: ['#nature', '#rose', '#red'],
  ),
  ExplorePhoto(
    id: '2',
    name: 'Lily',
    imageUrl: 'assets/images/lily.jpg',
    dateAdded: DateTime.now().subtract(const Duration(days: 5)),
    likes: 85,
    commentsCount: 2,
    username: 'ali_art',
    userAvatar: 'assets/images/lily.jpg',
    isOwner: false,
    caption: 'White lilies signify purity.',
    tags: ['#lily', '#white', '#pure'],
  ),
  ExplorePhoto(
    id: '3',
    name: 'Tulip',
    imageUrl: 'assets/images/tulip.jpg',
    dateAdded: DateTime.now().subtract(const Duration(days: 1)),
    likes: 250,
    commentsCount: 12,
    username: 'sara_garden',
    userAvatar: 'assets/images/tulip.jpg',
    isOwner: false,
    caption: 'Spring is here with Tulips.',
    tags: ['#spring', '#tulip'],
  ),
  ExplorePhoto(
    id: '4',
    name: 'Sunflower',
    imageUrl: 'assets/images/sunflower.jpg',
    dateAdded: DateTime.now().subtract(const Duration(days: 10)),
    likes: 45,
    username: 'john_doe',
    userAvatar: 'assets/images/sunflower.jpg',
    caption: 'Follow the sun.',
    tags: ['#sun', '#yellow'],
  ),
  ExplorePhoto(
    id: '5',
    name: 'Daffodil',
    imageUrl: 'assets/images/daffodil.jpg',
    dateAdded: DateTime.now().subtract(const Duration(days: 3)),
    likes: 310,
    username: 'mahsa_flower',
    userAvatar: 'assets/images/rose.jpg',
    isOwner: true,
    caption: 'Yellow brightens the day.',
    tags: ['#yellow', '#daffodil'],
  ),
  ExplorePhoto(
    id: '6',
    name: 'Peony',
    imageUrl: 'assets/images/peony.jpg',
    dateAdded: DateTime.now().subtract(const Duration(days: 7)),
    likes: 95,
    username: 'art_lover',
    userAvatar: 'assets/images/peony.jpg',
    caption: 'Pink peonies are the best.',
    tags: ['#pink', '#peony'],
  ),
];

List<ExploreAlbum> mockAlbums = [
  ExploreAlbum(
    id: 'a1',
    title: 'Trip to North',
    imageUrls: ['assets/images/rose.jpg', 'assets/images/lily.jpg', 'assets/images/tulip.jpg'],
    photoCount: 12,
  ),
  ExploreAlbum(
    id: 'a2',
    title: 'Family Gatherings',
    imageUrls: ['assets/images/sunflower.jpg', 'assets/images/daffodil.jpg'],
    photoCount: 5,
  ),
];
