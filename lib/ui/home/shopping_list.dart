import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:fridge_it/theme/theme_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import '../../widgets/dialog.dart';
import '../../widgets/small_text.dart';
import '../../utils/dimensions.dart';
import '../../widgets/big_text.dart';
import '../../widgets/text_field.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingList();
}

class _ShoppingList extends State<ShoppingList>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFirestoreService fbS = FirebaseFirestoreService();

  final TextEditingController _product = TextEditingController();

  CustomToast? toast;

  late AnimationController controller;
  late Animation<double> animation;

  ScrollController scrollViewColtroller = ScrollController();
  bool _direction = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )
      ..forward()
      ..repeat(reverse: true);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);

    scrollViewColtroller = ScrollController();
    scrollViewColtroller.addListener(_scrollListener);
  }

  _scrollListener() {
    if (scrollViewColtroller.offset >=
            scrollViewColtroller.position.maxScrollExtent &&
        !scrollViewColtroller.position.outOfRange) {
      setState(() {
        _direction = true;
      });
    }
    if (scrollViewColtroller.offset <=
            scrollViewColtroller.position.minScrollExtent &&
        !scrollViewColtroller.position.outOfRange) {
      setState(() {
        _direction = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    scrollViewColtroller.dispose();
  }

  _moveUp() {
    scrollViewColtroller.animateTo(
        scrollViewColtroller.position.minScrollExtent,
        curve: Curves.linear,
        duration: Duration(milliseconds: 500));
  }

  _moveDown() {
    scrollViewColtroller.animateTo(
        scrollViewColtroller.position.maxScrollExtent,
        curve: Curves.linear,
        duration: Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeColors().background,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Visibility(
              visible: _direction,
              maintainSize: false,
              child: FloatingActionButton(
                backgroundColor: ThemeColors().light1,
                onPressed: () {
                  _moveUp();
                },
                child: const RotatedBox(
                    quarterTurns: 1, child: Icon(Icons.chevron_left)),
              ),
            ),
            Visibility(
              maintainSize: false,
              visible: !_direction,
              child: FloatingActionButton(
                backgroundColor: ThemeColors().light1,
                onPressed: () {
                  _moveDown();
                },
                child: const RotatedBox(
                    quarterTurns: 3, child: Icon(Icons.chevron_left)),
              ),
            )
          ],
        ),
        body: NotificationListener<ScrollUpdateNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollViewColtroller.position.userScrollDirection ==
                  ScrollDirection.reverse) {
                print('User is going down');
                setState(() {
                  _direction = true;
                });
              } else {
                if (scrollViewColtroller.position.userScrollDirection ==
                    ScrollDirection.forward) {
                  print('User is going up');
                  setState(() {
                    _direction = false;
                  });
                }
              }
              return true;
            },
            child: Padding(
              padding: EdgeInsets.all(Dimensions.size15),
              child: Column(
                children: [
                  //Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BigText(
                          text: 'Shopping List',
                          size: Dimensions.size25,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors().main),
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.size25,
                  ),
                  //Body
                  Expanded(
                    child: SizedBox(
                      height: Dimensions.size200,
                      child: StreamBuilder(
                        stream: _firestore
                            .collection(_auth.currentUser!.uid)
                            .doc('user_data')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          } else {
                            if (snapshot.data!['shopping_list'].length == 0) {
                              return Center(
                                  child: Column(children: [
                                SizedBox(
                                  height: Dimensions.size150,
                                ),
                                AnimatedIcon(
                                  icon: AnimatedIcons.list_view,
                                  color: ThemeColors().light1,
                                  progress: animation,
                                  size: Dimensions.size30,
                                  semanticLabel: 'Show menu',
                                ),
                                SizedBox(
                                  height: Dimensions.size15,
                                ),
                                SmallText(
                                  text: 'There is no products yet',
                                  size: Dimensions.size15,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeColors().main,
                                ),
                              ]));
                            } else {
                              return ListView.builder(
                                controller: scrollViewColtroller,
                                itemCount:
                                    snapshot.data!['shopping_list'].length,
                                itemBuilder: (_, index) {
                                  return SizedBox(
                                    height: Dimensions.size20 * 5,
                                    width: double.maxFinite,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              ThemeColors().main.withOpacity(0),
                                          radius:
                                              Dimensions.size40, // Image radius
                                          backgroundImage: NetworkImage(
                                            snapshot.data!['shopping_list']
                                                [index]['image'],
                                          ),
                                        ),
                                        Expanded(
                                            child: SizedBox(
                                          height: Dimensions.size100,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  BigText(
                                                    text: snapshot.data![
                                                            'shopping_list']
                                                        [index]['name'],
                                                    color: ThemeColors().main,
                                                    size: Dimensions.size20,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(
                                                      Dimensions.size10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        Dimensions.size20,
                                                      ),
                                                      color:
                                                          ThemeColors().light1,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (snapshot.data![
                                                                            'shopping_list']
                                                                        [index][
                                                                    'quantity'] <=
                                                                1) {
                                                              toast = CustomToast(
                                                                  message:
                                                                      "The product has been removed\nfrom the shopping cart",
                                                                  context:
                                                                      context);
                                                              toast
                                                                  ?.showCustomToast();
                                                            }
                                                            fbS.removeItemToProduct(
                                                                snapshot.data![
                                                                    'shopping_list'],
                                                                index);
                                                          },
                                                          child: Icon(
                                                            Icons.remove,
                                                            color: ThemeColors()
                                                                .main,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 5.0,
                                                          ),
                                                          child: BigText(
                                                            text: snapshot
                                                                .data![
                                                                    'shopping_list']
                                                                    [index]
                                                                    ['quantity']
                                                                .toString(),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            fbS.addItemToProduct(
                                                                snapshot.data![
                                                                    'shopping_list'],
                                                                index);
                                                          },
                                                          child: Icon(
                                                            Icons.add,
                                                            color: ThemeColors()
                                                                .main,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
