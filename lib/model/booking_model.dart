import 'package:gym_finder/model/contact_model.dart';
import 'package:gym_finder/model/posting_model.dart';

class BookingModel {
  String id = "";
  PostingModel? posting;
  ContactModel? contact;
  List<DateTime>? dates;
  BookingModel();
}
