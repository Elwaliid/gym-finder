// ignore_for_file: sort_child_properties_last, use_super_parameters

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym_finder/global.dart';
import 'package:gym_finder/model/app_constants.dart';
import 'package:gym_finder/model/posting_model.dart';
import 'package:gym_finder/view/userScreens/user_home_screen.dart';
import 'package:image_picker/image_picker.dart';

// Extension to convert List<String> of file paths to List<MemoryImage>

class CreatePostingScreen extends StatefulWidget {
  final PostingModel? posting;

  // ignore: prefer_const_constructors_in_immutables
  CreatePostingScreen({Key? key, this.posting}) : super(key: key);

  @override
  State<CreatePostingScreen> createState() => _CreatePostingScreenState();
}

class _CreatePostingScreenState extends State<CreatePostingScreen> {
  final formkey = GlobalKey<FormState>();

  // Focus nodes for each sport type and price duration
  Map<String, Map<String, FocusNode>> priceFocusNodes = {};
  late FocusNode _nameFocusNode;
  late FocusNode _descriptionFocusNode;
  late FocusNode _addressFocusNode;
  late FocusNode _cityFocusNode;
  late FocusNode _stateFocusNode;
  late FocusNode _phoneFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _placesFocusNode;

  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _descriptionTextEditingController =
      TextEditingController();
  final TextEditingController _adressTextEditingController =
      TextEditingController();
  final TextEditingController _cityTextEditingController =
      TextEditingController();
  final TextEditingController _stateTextEditingController =
      TextEditingController();
  final TextEditingController _phoneTextEditingController =
      TextEditingController();
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _placesTextEditingController =
      TextEditingController();

  final List<String> types = [
    'Box',
    'Judo',
    'wrestling',
    'jujutsou',
    'bodybuilding',
  ];

  List<String> typeSelected = [];

  bool showAddSportSection = false;

  // ignore: non_constant_identifier_names

  // Controllers for prices per type and duration
  Map<String, Map<String, TextEditingController>> priceControllers = {};

  List<String> pickedBase64Images = [];
  List<String> existingBase64Images = [];
  // List<MemoryImage>? _imagesList;

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode()..addListener(() => setState(() {}));
    _descriptionFocusNode = FocusNode()..addListener(() => setState(() {}));
    _addressFocusNode = FocusNode()..addListener(() => setState(() {}));
    _cityFocusNode = FocusNode()..addListener(() => setState(() {}));
    _stateFocusNode = FocusNode()..addListener(() => setState(() {}));
    _phoneFocusNode = FocusNode()..addListener(() => setState(() {}));
    _emailFocusNode = FocusNode()..addListener(() => setState(() {}));
    _placesFocusNode = FocusNode()..addListener(() => setState(() {}));
    initializeValues();
  }

  // Reusable widget for TextFormField with focus and icon
  Widget buildCustomTextFormField({
    required String labelText,
    required IconData iconData,
    required FocusNode focusNode,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int minLines = 1,
  }) {
    return TextFormField(
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          iconData,
          color: focusNode.hasFocus
              ? const Color.fromARGB(255, 188, 79, 46)
              : Colors.grey,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide:
              BorderSide(color: Color.fromARGB(255, 188, 79, 46), width: 2.0),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide:
              BorderSide(color: Color.fromARGB(255, 188, 79, 46), width: 2.0),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelStyle:
            const TextStyle(color: Color.fromARGB(255, 188, 79, 46)),
      ),
      style: const TextStyle(fontSize: 20.0, color: Colors.black),
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
    );
  }

  void initializeValues() {
    if (widget.posting == null) {
      _nameTextEditingController.text = "";
      _descriptionTextEditingController.text = "";
      _adressTextEditingController.text = "";
      _cityTextEditingController.text = "";
      _stateTextEditingController.text = "";
      _emailTextEditingController.text = AppConstants.currentUser.email ?? '';
      _phoneTextEditingController.text = "";
      _placesTextEditingController.text = "0";
      typeSelected = [];
      pickedBase64Images = [];
      existingBase64Images = [];
      priceControllers = {};
      priceFocusNodes = {};
      for (var type in typeSelected) {
        priceControllers[type] = {
          '1Month': TextEditingController(),
          '3Months': TextEditingController(),
          '1Year': TextEditingController(),
          '1Session': TextEditingController(),
        };
        priceFocusNodes[type] = {
          '1Month': FocusNode()..addListener(() => setState(() {})),
          '3Months': FocusNode()..addListener(() => setState(() {})),
          '1Year': FocusNode()..addListener(() => setState(() {})),
          '1Session': FocusNode()..addListener(() => setState(() {})),
        };
      }
    } else {
      _nameTextEditingController.text = widget.posting!.name ?? "";
      _descriptionTextEditingController.text =
          widget.posting!.description ?? "";
      _adressTextEditingController.text = widget.posting!.address ?? "";
      _cityTextEditingController.text = widget.posting!.city ?? "";
      _stateTextEditingController.text = widget.posting!.state ?? "";
      _emailTextEditingController.text = widget.posting!.email ?? "";
      _phoneTextEditingController.text = widget.posting!.phone ?? "";
      _placesTextEditingController.text = widget.posting!.places.toString();

      // ignore: unnecessary_null_comparison
      existingBase64Images = widget.posting!.imageNames != null
          ? List<String>.from(widget.posting!.imageNames)
          : [];
      pickedBase64Images = [];
      typeSelected = widget.posting!.type;

      priceControllers = {};
      priceFocusNodes = {};
      for (var type in typeSelected) {
        priceControllers[type] = {
          '1Month': TextEditingController(
              text: widget.posting!.pricesPerTypeDuration[type]?['1Month']
                      ?.toString() ??
                  ''),
          '3Months': TextEditingController(
              text: widget.posting!.pricesPerTypeDuration[type]?['3Months']
                      ?.toString() ??
                  ''),
          '1Year': TextEditingController(
              text: widget.posting!.pricesPerTypeDuration[type]?['1Year']
                      ?.toString() ??
                  ''),
          '1Session': TextEditingController(
              text: widget.posting!.pricesPerTypeDuration[type]?['1Session']
                      ?.toString() ??
                  ''),
        };
        priceFocusNodes[type] = {
          '1Month': FocusNode()..addListener(() => setState(() {})),
          '3Months': FocusNode()..addListener(() => setState(() {})),
          '1Year': FocusNode()..addListener(() => setState(() {})),
          '1Session': FocusNode()..addListener(() => setState(() {})),
        };
      }
    }
    setState(() {});
  }

  Future<void> pickImages() async {
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      List<String> base64Strings = [];
      for (XFile file in pickedFiles) {
        final bytes = await file.readAsBytes();
        base64Strings.add(base64Encode(bytes));
      }
      setState(() {
        pickedBase64Images = [...pickedBase64Images, ...base64Strings];
      });
    }
  }

  Future<void> changeImage(int index) async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      setState(() {
        if (index < pickedBase64Images.length) {
          pickedBase64Images[index] = base64String;
        } else {
          int existingIndex = index - pickedBase64Images.length;
          if (existingIndex >= 0 &&
              existingIndex < existingBase64Images.length) {
            existingBase64Images.removeAt(existingIndex);
            pickedBase64Images.add(base64String);
          }
        }
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      if (index < pickedBase64Images.length) {
        pickedBase64Images.removeAt(index);
      } else {
        int existingIndex = index - pickedBase64Images.length;
        if (existingIndex >= 0 && existingIndex < existingBase64Images.length) {
          existingBase64Images.removeAt(existingIndex);
        }
      }
    });
  }

  void submitForm() async {
    try {
      if (!formkey.currentState!.validate()) {
        return;
      }
      if (typeSelected.isEmpty) {
        Get.snackbar("Error", "Please select at least one sport type");
        return;
      }

      postingModel.name = _nameTextEditingController.text;
      postingModel.description = _descriptionTextEditingController.text;
      postingModel.address = _adressTextEditingController.text;
      postingModel.city = _cityTextEditingController.text;
      postingModel.state = _stateTextEditingController.text;

      postingModel.type = typeSelected;

      postingModel.email = _emailTextEditingController.text;
      postingModel.phone = _phoneTextEditingController.text;
      postingModel.places =
          int.tryParse(_placesTextEditingController.text) ?? 0;

      // Collect prices per type and duration from controllers
      Map<String, Map<String, double>> pricesMap = {};
      for (var type in typeSelected) {
        pricesMap[type] = {};
        for (var duration in ['1Month', '3Months', '1Year', '1Session']) {
          String text = priceControllers[type]?[duration]?.text ?? '';
          double value = double.tryParse(text) ?? 0.0;
          pricesMap[type]![duration] = value;
        }
      }
      postingModel.pricesPerTypeDuration = pricesMap;

      // Combine existing base64 images with newly picked images
      postingModel.imageNames = [
        ...existingBase64Images,
        ...pickedBase64Images
      ];

      postingModel.host = AppConstants.currentUser.creatUserFromContact();

      if (widget.posting == null) {
        postingModel.subscriptions = [];
        await postingViewModel.addListingInfoToFirestore();
        Get.snackbar("New Listing", "Your listing has uploaded successfully");
        postingModel = PostingModel();
        Get.to(const UserScreen());
      } else {
        postingModel.subscriptions = widget.posting!.subscriptions;
        postingModel.id = widget.posting!.id;
        for (int i = 0; i < AppConstants.currentUser.myPostings!.length; i++) {
          if (AppConstants.currentUser.myPostings![i].id == postingModel.id) {
            AppConstants.currentUser.myPostings![i] = postingModel;
            break;
          }
        }
        await postingViewModel.updatePostingInfoFirestore(
            pickedBase64Images: pickedBase64Images,
            existingBase64Images: existingBase64Images);
        Get.snackbar("Update Listing", "Your listing has updated successfully");
        postingModel = PostingModel();
        Get.to(const UserScreen());
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error in submitForm: $e");
      Get.snackbar("Error", "An unexpected error occurred.");
    }
  }

  @override
  Widget build(BuildContext context) {
    const InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: Color.fromARGB(255, 188, 79, 46), width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: Color.fromARGB(255, 188, 79, 46), width: 2.0),
      ),
      labelStyle: TextStyle(
        color: Color.fromARGB(255, 188, 79, 46),
      ),
      floatingLabelStyle: TextStyle(
        color: Color.fromARGB(255, 188, 79, 46),
      ),
      border: OutlineInputBorder(),
    );

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 188, 79, 46),
                Color.fromARGB(255, 232, 197, 145),
              ],
              begin: FractionalOffset(0, 0),
              end: FractionalOffset(1, 0),
              stops: [0, 1],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text(
          "Create / Update a posting",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 26, 26, 0),
            child: Form(
              key: formkey,
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: inputDecorationTheme,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Listing Name
                    buildCustomTextFormField(
                      labelText: "Gym name",
                      iconData: Icons.other_houses,
                      focusNode: _nameFocusNode,
                      controller: _nameTextEditingController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a valid name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 188, 79, 46),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Grouped sport type dropdown and price input
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: types.map((sport) {
                                    final bool isSelected =
                                        typeSelected.contains(sport);
                                    return ChoiceChip(
                                      label: Text(sport),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            if (!typeSelected.contains(sport)) {
                                              typeSelected.add(sport);
                                              // Initialize price controllers for new type
                                              priceControllers[sport] = {
                                                '1Month':
                                                    TextEditingController(),
                                                '3Months':
                                                    TextEditingController(),
                                                '1Year':
                                                    TextEditingController(),
                                                '1Session':
                                                    TextEditingController(),
                                              };
                                              priceFocusNodes[sport] = {
                                                '1Month': FocusNode()
                                                  ..addListener(
                                                      () => setState(() {})),
                                                '3Months': FocusNode()
                                                  ..addListener(
                                                      () => setState(() {})),
                                                '1Year': FocusNode()
                                                  ..addListener(
                                                      () => setState(() {})),
                                                '1Session': FocusNode()
                                                  ..addListener(
                                                      () => setState(() {})),
                                              };
                                            }
                                          } else {
                                            typeSelected.remove(sport);
                                            priceControllers.remove(sport);
                                            // Dispose and remove focus nodes for removed sport
                                            if (priceFocusNodes
                                                .containsKey(sport)) {
                                              priceFocusNodes[sport]
                                                  ?.forEach((key, node) {
                                                node.dispose();
                                              });
                                              priceFocusNodes.remove(sport);
                                            }
                                          }
                                        });
                                      },
                                      selectedColor: const Color.fromARGB(
                                          255, 188, 79, 46),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Price inputs per selected type and duration
                          ...typeSelected.map((type) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Prices for $type",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                buildCustomTextFormField(
                                  labelText: "Price for 1 Month",
                                  iconData: Icons.attach_money,
                                  focusNode: priceFocusNodes[type]?['1Month'] ??
                                      FocusNode(),
                                  controller: priceControllers[type]
                                          ?['1Month'] ??
                                      TextEditingController(),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter a valid price for 1 month";
                                    }
                                    if (double.tryParse(value) == null) {
                                      return "Please enter a valid number";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                buildCustomTextFormField(
                                  labelText: "Price for 3 Months",
                                  iconData: Icons.attach_money,
                                  focusNode: priceFocusNodes[type]
                                          ?['3Months'] ??
                                      FocusNode(),
                                  controller: priceControllers[type]
                                          ?['3Months'] ??
                                      TextEditingController(),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      if (double.tryParse(value) == null) {
                                        return "Please enter a valid number";
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                buildCustomTextFormField(
                                  labelText: "Price for 1 Year",
                                  iconData: Icons.attach_money,
                                  focusNode: priceFocusNodes[type]?['1Year'] ??
                                      FocusNode(),
                                  controller: priceControllers[type]
                                          ?['1Year'] ??
                                      TextEditingController(),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      if (double.tryParse(value) == null) {
                                        return "Please enter a valid number";
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                buildCustomTextFormField(
                                  labelText: "Price for 1 Session",
                                  iconData: Icons.attach_money,
                                  focusNode: priceFocusNodes[type]
                                          ?['1Session'] ??
                                      FocusNode(),
                                  controller: priceControllers[type]
                                          ?['1Session'] ??
                                      TextEditingController(),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      if (double.tryParse(value) == null) {
                                        return "Please enter a valid number";
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                            // ignore: unnecessary_to_list_in_spreads
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description
                    buildCustomTextFormField(
                      labelText: "Description",
                      iconData: Icons.description,
                      focusNode: _descriptionFocusNode,
                      controller: _descriptionTextEditingController,
                      maxLines: 3,
                      minLines: 1,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a valid description";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Phone
                    buildCustomTextFormField(
                      labelText: "Phone Number",
                      iconData: Icons.phone,
                      focusNode: _phoneFocusNode,
                      controller: _phoneTextEditingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a phone number";
                        }
                        if (value.length != 10) {
                          return "Phone number must be exactly 10 digits";
                        }
                        if (!(value.startsWith('03') ||
                            value.startsWith('05') ||
                            value.startsWith('06') ||
                            value.startsWith('07'))) {
                          return "Phone number must start with 05, 06, or 07";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Address group: Address, City, State
                    buildCustomTextFormField(
                      labelText: "Address",
                      iconData: Icons.location_on,
                      focusNode: _addressFocusNode,
                      controller: _adressTextEditingController,
                      maxLines: 3,
                      minLines: 1,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a valid address";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: buildCustomTextFormField(
                            labelText: "City",
                            iconData: Icons.location_city,
                            focusNode: _cityFocusNode,
                            controller: _cityTextEditingController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z]')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a valid city";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: buildCustomTextFormField(
                            labelText: "State",
                            iconData: Icons.map,
                            focusNode: _stateFocusNode,
                            controller: _stateTextEditingController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z]')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a valid state";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Email
                    buildCustomTextFormField(
                      labelText: "Email",
                      iconData: Icons.email,
                      focusNode: _emailFocusNode,
                      controller: _emailTextEditingController,
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Places available
                    buildCustomTextFormField(
                      labelText: "Places available",
                      iconData: Icons.event_seat,
                      focusNode: _placesFocusNode,
                      controller: _placesTextEditingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the number of places available";
                        }
                        if (int.tryParse(value) == null) {
                          return "Please enter a valid integer";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Photos section
                    const Text(
                      'Photos',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Center(
                      child: (pickedBase64Images.isNotEmpty ||
                              existingBase64Images.isNotEmpty)
                          ? Wrap(
                              spacing: 15,
                              runSpacing: 15,
                              children: [
                                ...pickedBase64Images
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  String base64String = entry.value;
                                  final decodedBytes =
                                      base64Decode(base64String);
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: MemoryImage(decodedBytes),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 27,
                                        child: GestureDetector(
                                          onTap: () => removeImage(index),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await changeImage(index);
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                ...existingBase64Images
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index =
                                      entry.key + pickedBase64Images.length;
                                  String base64String = entry.value;
                                  final decodedBytes =
                                      base64Decode(base64String);
                                  return Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: MemoryImage(decodedBytes),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 27,
                                        child: GestureDetector(
                                          onTap: () => removeImage(index),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await changeImage(index);
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    Center(
                      child: IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        iconSize: 40,
                        onPressed: pickImages,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Submit button
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 188, 79, 46),
                            Color.fromARGB(255, 232, 197, 145),
                          ],
                          begin: FractionalOffset(0, 0),
                          end: FractionalOffset(1, 0),
                          stops: [0, 1],
                          tileMode: TileMode.clamp,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.upload,
                          color: Colors.white,
                        ),
                        label: const Text('Upload Listing',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: submitForm,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
