// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_rental/controller/extention.dart';
import 'package:home_rental/view/details_page/details_page.dart';
import 'package:home_rental/view/post_data/user_data_post.dart';
import 'package:home_rental/widgets/homepage_widget.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:home_rental/models/allposts_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

String? message;
List<User>? users;
// String _text = '';

class _HomeScreenState extends State<HomeScreen> {
  Future fetchAllPosts() async {
    final response = await http
        .get(Uri.parse('https://homeforrent.herokuapp.com/api/getallposts'));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      message = jsonResponse['message'].toString();
      var list = jsonResponse['users'] as List;

      users = list.map((user) => User.fromJson(user)).toList();

      print(message);
      print(users!.length);
      print(users![1].address);
      print(users![1].username);
    } else {
      message = 'Request failed with status: ${response.statusCode}';
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: SpeedDial(
          child: const Icon(Icons.add),
          backgroundColor: Colors.deepPurple,
          activeBackgroundColor: Colors.black,
          overlayOpacity: 0.4,
          spaceBetweenChildren: 8,
          children: <SpeedDialChild>[
            SpeedDialChild(
              child: const Icon(Icons.post_add),
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepPurple[400],
              label: 'Post',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const PostData()));
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.settings),
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepPurple[400],
              label: 'Settings',
              onTap: () {},
            ),
          ],
        ),
        body: NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              // Another Widget can be added
              SliverPersistentHeader(
                delegate: MySliverAppBar(expandedHeight: 200),
                pinned: false,
              )
            ];
          },
          body: Container(
            color: Colors.deepPurple[100],
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  fetchAllPosts();
                });
              },
              child: FutureBuilder(
                future: fetchAllPosts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DetailsPage(
                                      // users: users![index],
                                      ),
                                  settings: RouteSettings(
                                    arguments: users![index],
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                users![index]
                                                    .picture
                                                    .toString(),
                                                fit: BoxFit.cover,
                                                height: 250 *
                                                    MediaQuery.of(context)
                                                        .size
                                                        .aspectRatio,
                                                width: 300 *
                                                    MediaQuery.of(context)
                                                        .size
                                                        .aspectRatio,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${users![index].owner}'
                                                    .toTitleCase(),
                                                style: textStyle(
                                                    size: 22,
                                                    weight: FontWeight.w600),
                                              ),
                                              const CustomSizeBox(height: 10),
                                              Text(
                                                '${users![index].address}'
                                                    .toTitleCase(),
                                                overflow: TextOverflow.fade,
                                                maxLines: 1,
                                                softWrap: false,
                                                style: textStyle(),
                                              ),
                                              const CustomSizeBox(height: 10),
                                              Text(
                                                '${users![index].rent} Rs/month',
                                                style: textStyle(),
                                              ),
                                              const CustomSizeBox(height: 10),
                                              Text(
                                                '${users![index].size} sq. ft.',
                                                style: textStyle(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const CustomSizeBox(height: 10),
                                        IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                                Icons.favorite_border_outlined))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: users == null ? 0 : users!.length);
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        ));
  }

  TextStyle textStyle({
    double? size,
    FontWeight? weight,
    MaterialColor? color,
  }) =>
      TextStyle(
        fontSize: size ?? 18,
        fontWeight: weight ?? FontWeight.normal,
        color: color ?? Colors.black,
      );
}
