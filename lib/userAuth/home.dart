import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe/consent/appbar.dart';
import 'package:recipe/consent/colors.dart';
import 'package:recipe/screen/recipe.dart';
import 'package:recipe/userAuth/toast.dart';
import 'package:recipe/consent/favoritesManager.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int indexx = 0;
  List<String> category = ['All', 'Padang', 'Chinese', 'Betawi'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: appbar(context), // Pass the context to the appbar function
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No recipes found.'));
          }
          var recipes = snapshot.data!.docs;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Text(
                    'Popular Category',
                    style: TextStyle(
                      fontSize: 20,
                      color: font,
                      fontFamily: 'ro',
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        child: ListView.builder(
                          itemCount: category.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: ((context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    indexx = index;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    left: index == 0 ? 4 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: indexx == index ? maincolor : Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: indexx == index ? maincolor : Colors.transparent,
                                        offset: indexx == index ? Offset(1, 1) : Offset(0, 0),
                                        blurRadius: indexx == index ? 7 : 0,
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 17),
                                      child: Text(
                                        category[index],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: indexx == index ? Colors.white : font,
                                          fontFamily: 'ro',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            'Popular',
                            style: TextStyle(
                              fontSize: 20,
                              color: font,
                              fontFamily: 'ro',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      var recipe = recipes[index];
                      final recipeName = recipe['recipeName'];
                      final isFavorite = recipe['favoriteState'];
                      final thumbnailUrl = recipe['thumbnailUrl'] ?? 'https://via.placeholder.com/150'; // Fallback image
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => Recipe(
                                recipeId: recipe.id,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 185, 185, 185),
                                offset: Offset(1, 1),
                                blurRadius: 15,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          toggleFavorite(recipe.id);
                                        });
                                      },
                                      child: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? maincolor : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(thumbnailUrl),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                recipeName,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: font,
                                  fontFamily: 'ro',
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    '100 min',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontFamily: 'ro',
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: maincolor, size: 15),
                                      Text(
                                        '4.2',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          fontFamily: 'ro',
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: recipes.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 270,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void toggleFavorite(String recipeId) async {
    var recipeRef = FirebaseFirestore.instance.collection('recipes').doc(recipeId);
    var recipe = await recipeRef.get();
    await recipeRef.update({
      'favoriteState': !recipe['favoriteState'],
    });
  }
}