import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:gym_finder/global.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/posting_model.dart';
import 'package:gym_finder/view/host_home_screen.dart';
import 'package:gym_finder/view/widgets/amenities_ui.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostingScreen extends StatefulWidget {
  PostingModel? posting;

  CreatePostingScreen({super.key, this.posting});

  @override
  State<CreatePostingScreen> createState() => _CreatePostingScreen();
}

class _CreatePostingScreen extends State<CreatePostingScreen> {
  final formkey = GlobalKey<FormState>();
  TextEditingController _nameTextEditingController = TextEditingController();
  TextEditingController _priceTextEditingController = TextEditingController();
  TextEditingController _descriptionTextEditingController =
      TextEditingController();
  TextEditingController _adressTextEditingController = TextEditingController();
  TextEditingController _cityTextEditingController = TextEditingController();
  TextEditingController _countryTextEditingController = TextEditingController();
  TextEditingController _amenitiesTextEditingController =
      TextEditingController();

  final List<String> residenceTypes = [
    'Box',
    'Judo',
    'wrestling',
    'jujutsou',
  ];

  String? residenceTypeSelected = "";

  Map<String, int>? _Beds;
  Map<String, int>? _Bathrooms;
//lllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll
  /*List<MemoryImage>? _imagesList;
  _selectImageFromGallery(int index) async {
    var imageFilePickedFromGalery =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imageFilePickedFromGalery != null) {
      MemoryImage imageFileInbytsForm =
          MemoryImage((File(imageFilePickedFromGalery.path)).readAsBytesSync());
//fgh
      if (index < 0) {
        _imagesList!.add(imageFileInbytsForm);
      } else {
        _imagesList![index] = imageFileInbytsForm;
      }
      setState(() {});
    }
  }*/

  initializeValues() {
    _nameTextEditingController = TextEditingController(text: "");
    _priceTextEditingController = TextEditingController(text: "");
    _descriptionTextEditingController = TextEditingController(text: "");
    _adressTextEditingController = TextEditingController(text: "");
    _cityTextEditingController = TextEditingController(text: "");
    _countryTextEditingController = TextEditingController(text: "");
    _adressTextEditingController = TextEditingController(text: "");

    residenceTypeSelected = residenceTypes.first;

    _Beds = {'small': 0, 'medium': 0, 'large': 0};

    _Bathrooms = {'full': 0, 'half': 0};

    // _imagesList = [];
  }

  @override
  void initState() {
    //TODO: implement initState
    super.initState();
    initializeValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pinkAccent,
              Colors.amber,
            ],
            begin: FractionalOffset(0, 0),
            end: FractionalOffset(1, 0),
            stops: [0, 1],
            tileMode: TileMode.clamp,
          ),
        )),
        title: const Text(
          "Create / Update a posting",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                if (!formkey.currentState!.validate()) {
                  return;
                }
                if (residenceTypeSelected == "") {
                  return;
                }
                // if (_imagesList!.isEmpty) {
                //  return;
                // }
                String? name = _nameTextEditingController.text;
                String? price = _priceTextEditingController.text;
                String? description = _descriptionTextEditingController.text;
                String? address = _adressTextEditingController.text;
                String? city = _cityTextEditingController.text;
                String? country = _countryTextEditingController.text;
                String? amenities = _amenitiesTextEditingController.text;

                if (name == null ||
                    price == null ||
                    description == null ||
                    address == null ||
                    city == null ||
                    country == null ||
                    amenities == null) {
                  Get.snackbar('Error', 'Please fill out all fields');
                  return;
                }

                double? priceValue = double.tryParse(price);
                if (priceValue == null) {
                  Get.snackbar('Error', 'Invalid price format');
                  return;
                }
                postingModel.name = _nameTextEditingController.text;
                postingModel.price =
                    double.parse(_priceTextEditingController.text);
                postingModel.description =
                    _descriptionTextEditingController.text;
                postingModel.address = _adressTextEditingController.text;
                postingModel.city = _cityTextEditingController.text;
                postingModel.country = _countryTextEditingController.text;
                postingModel.amenities =
                    _amenitiesTextEditingController.text.split(",");
                postingModel.type = residenceTypeSelected;
                postingModel.beds = _Beds;
                postingModel.bathrooms = _Bathrooms;
                //  postingModel.displayImages = _imagesList;
                postingModel.host =
                    AppConstants.currentUser.creatUserFromContact();
                //  postingModel.setImagesNames();
//if this is new post or old post(update)
                postingModel.rating = 3.5;
                postingModel.bookings = [];
                postingModel.reviews = [];

                await postingViewModel.addListingInfoToFirestore();
//lllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll
                //     await postingViewModel.addImagesToFirebaseStorage();

                Get.to(const HostHomeScreen());
              },
              icon: const Icon(Icons.upload))
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 26, 26, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Form(
                    key: formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Listing Name
                        Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: TextFormField(
                              decoration: const InputDecoration(
                                  labelText: "Listing name"),
                              style: const TextStyle(
                                fontSize: 25.0,
                              ),
                              controller: _nameTextEditingController,
                              validator: (TextInput) {
                                if (TextInput!.isEmpty) {
                                  return "please enter a valid name";
                                }
                                return null;
                              }),
                        ),

                        //Slecet Sport Type /property type
                        Padding(
                          padding: const EdgeInsets.only(top: 28.0),
                          child: DropdownButton(
                              items: residenceTypes.map((item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (valueItem) {
                                setState(() {
                                  residenceTypeSelected = valueItem.toString();
                                });
                              },
                              isExpanded: true,
                              value: residenceTypeSelected,
                              hint: const Text(
                                "Select Sport Type",
                                style: TextStyle(fontSize: 20),
                              )),
                        ),

                        //price / month
                        Padding(
                          padding: const EdgeInsets.only(top: 21.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  decoration:
                                      const InputDecoration(labelText: "Price"),
                                  style: const TextStyle(
                                    fontSize: 25.0,
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: _priceTextEditingController,
                                  validator: (Text) {
                                    if (Text!.isEmpty) {
                                      return "please enter a valid price";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 10.0, bottom: 10.0),
                                child: Text(
                                  "\$ / month",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        //Description
                        Padding(
                          padding: const EdgeInsets.only(top: 21.0),
                          child: TextFormField(
                              decoration: const InputDecoration(
                                  labelText: "Description"),
                              style: const TextStyle(
                                fontSize: 25.0,
                              ),
                              controller: _descriptionTextEditingController,
                              maxLines: 3,
                              minLines: 1,
                              validator: (Text) {
                                if (Text!.isEmpty) {
                                  return "please enter a valid description";
                                }
                                return null;
                              }),
                        ),

                        //Adress
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: TextFormField(
                              enabled: true,
                              decoration:
                                  const InputDecoration(labelText: "Adress"),
                              maxLines: 3,
                              style: const TextStyle(fontSize: 25.0),
                              controller: _adressTextEditingController,
                              validator: (Text) {
                                if (Text!.isEmpty) {
                                  return "please enter a valid Adress";
                                }
                                return null;
                              }),
                        ),

                        //places AVAILABLE // beds
                        const Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Text(
                            "Places",
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                              top: 21.0, left: 15.0, right: 15.0),
                          child: Column(
                            children: <Widget>[
                              // lllllllllllllllllllllllllllllllllllllllllllllllllllllllll   PLaces///type: 'Twin/Single
                              AmenitiesUI(
                                type: 'Twin/Single',
                                startValue: _Beds!['small']!,
                                decreaseValue: () {
                                  _Beds!['small'] = _Beds!['small']! - 1;
                                  if (_Beds!['small']! < 0) {
                                    _Beds!['small'] = 0;
                                  }
                                },
                                increaseValue: () {
                                  _Beds!['small'] = _Beds!['small']! + 1;
                                },
                              ),
                              //  /double bed
                              AmenitiesUI(
                                type: 'Double',
                                startValue: _Beds!['medium']!,
                                decreaseValue: () {
                                  _Beds!['medium'] = _Beds!['medium']! - 1;
                                  if (_Beds!['medium']! < 0) {
                                    _Beds!['medium'] = 0;
                                  }
                                },
                                increaseValue: () {
                                  _Beds!['medium'] = _Beds!['medium']! + 1;
                                },
                              ),
                              // king bed
                              AmenitiesUI(
                                type: 'king',
                                startValue: _Beds!['large']!,
                                decreaseValue: () {
                                  _Beds!['large'] = _Beds!['large']! - 1;
                                  if (_Beds!['large']! < 0) {
                                    _Beds!['large'] = 0;
                                  }
                                },
                                increaseValue: () {
                                  _Beds!['large'] = _Beds!['large']! + 1;
                                },
                              ),
                            ],
                          ),
                        ),

                        //bathrooms
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Text(
                            'Bathrooms',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
//asasasas
                        Padding(
                          padding: EdgeInsets.fromLTRB(15, 25, 15, 0),
                          child: Column(
                            children: <Widget>[
                              //full bathrooms
                              AmenitiesUI(
                                type: 'Full',
                                startValue: _Bathrooms!['full']!,
                                decreaseValue: () {
                                  _Bathrooms!['full'] =
                                      _Bathrooms!['full']! - 1;
                                  if (_Bathrooms!['full']! < 0) {
                                    _Bathrooms!['full'] = 0;
                                  }
                                },
                                increaseValue: () {
                                  _Bathrooms!['full'] =
                                      _Bathrooms!['full']! + 1;
                                },
                              ),

                              //half bathrroms
                              AmenitiesUI(
                                type: 'Half',
                                startValue: _Bathrooms!['half']!,
                                decreaseValue: () {
                                  _Bathrooms!['half'] =
                                      _Bathrooms!['half']! - 1;
                                  if (_Bathrooms!['half']! < 0) {
                                    _Bathrooms!['half'] = 0;
                                  }
                                },
                                increaseValue: () {
                                  _Bathrooms!['half'] =
                                      _Bathrooms!['half']! + 1;
                                },
                              )

                              //
                            ],
                          ),
                        ),

                        // extra amenities
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 21.0,
                          ),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Amenities, (coma separated)",
                            ),
                            style: const TextStyle(
                              fontSize: 25.0,
                            ),
                            controller: _amenitiesTextEditingController,
                            validator: (text) {
                              if (text!.isEmpty) {
                                return 'Amenities cannot be empty';
                              }
                              return null;
                            },
                            maxLines: 3,
                            minLines: 1,
                          ),
                        ),

                        //photos llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll
                        /*    const Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Text(
                            'Photos',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),

                        Padding(
                          padding:
                              const EdgeInsets.only(top: 20.0, bottom: 25.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            itemCount: (_imagesList ?? []).length + 1,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 25,
                              crossAxisSpacing: 25,
                              childAspectRatio: 3 / 2,
                            ),
                            itemBuilder: (context, index) {
                              if (index == (_imagesList ?? []).length) {
                                return IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    _selectImageFromGallery(-1);
                                  },
                                );
                              } else {
                                return MaterialButton(
                                  onPressed: () {},
                                  child: Image(
                                    image: _imagesList![index],
                                    fit: BoxFit.fill,
                                  ),
                                );
                              }
                            },
                          ),
                        ),*/
                      ],
                    ),
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
