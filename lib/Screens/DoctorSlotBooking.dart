import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freelance_booking_app/Models/Cart.dart';
import 'package:freelance_booking_app/Models/Medical.dart';
import 'package:freelance_booking_app/Models/Parlour.dart';
import 'package:freelance_booking_app/Providers/cartServices.dart';
import 'package:freelance_booking_app/Providers/database.dart';
import 'package:freelance_booking_app/Providers/navigationProvider.dart';
import 'package:freelance_booking_app/Widgets/LowerTotalService.dart';
import 'package:freelance_booking_app/Widgets/UpperCardDoctorBooking.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:table_calendar/table_calendar.dart';

class DoctorSlotBooking extends StatefulWidget {
  final DoctorDetails doctorDetail;
  final ClinicLocationAndDoctor clinicLocationAndDoctor;
  const DoctorSlotBooking(
      {Key key, this.doctorDetail, this.clinicLocationAndDoctor})
      : super(key: key);

  @override
  _DoctorSlotBookingState createState() => _DoctorSlotBookingState();
}

class _DoctorSlotBookingState extends State<DoctorSlotBooking> {
  String sl;
  bool dateSelected = false;
  bool slotSelected = false;
  bool changeDate = false;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.utc(1989);
  CalendarFormat _calendarFormat = CalendarFormat.week;
  int intervalDuration = 0;
  int slotDuration = 60;
  int count = 0, tempCount = 0;
  // int Min1 = 0,
  //     Hr1 = 0,
  //     Min2 = 0,
  //     Hr2 = 0,
  //     Min3 = 0,
  //     Hr3 = 0,
  //     Min4 = 0,
  //     Hr4 = 0;

  // List<bool> slotButtons = List.filled(30, false, growable: false);
  // var am_pm1 = [
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM'
  // ];
  // var am_pm2 = [
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM'
  // ];
  // var am_pm3 = [
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM'
  // ];
  // var am_pm4 = [
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM',
  //   'AM'
  // ];

  setIsChecked(bool val) {
    setState(() {
      isChecked = val;
    });
  }

  bool isChecked = false;

  String lessMins1 = '', lessMins2 = '', lessMins3 = '', lessMins4 = '';

  bool pm = false, stop1 = false, stop2 = false;
  int rim = 0;

  final _db = DatabaseService();

  String _selectedDateForKey = "";
  int slotIndexSelected = -1;

  confirmBooking(
      Cart _service,
      String id,
      Map bookedSlotsPerDay,
      int slotIndexSelected,
      String _selectedDateForKey,
      DoctorDetails selectedDoctor) async {
    String otp = randomAlphaNumeric(6);
    _service.addOtp(otp);
    _service.addGST(_service.subtotal.toInt());
    _db.addBookingofCustomer(_service, id.toString());
    _db.addCustomerBookingToServiceProvider(_service, id.toString());

    if (bookedSlotsPerDay == null) {
      DatabaseService().upgradeClinicBookedSlotsDatabaseFirst(
        id,
        slotIndexSelected,
        selectedDoctor.dividedSlots,
        _selectedDateForKey,
        selectedDoctor,
      );
    } else {
      DatabaseService().upgradeClinicBookedSlotsDatabaseExisting(
        id,
        slotIndexSelected,
        bookedSlotsPerDay,
        selectedDoctor.dividedSlots,
        _selectedDateForKey,
        selectedDoctor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final int employeeNumbers = 2;
    final id =
        widget.clinicLocationAndDoctor.serviceUid + widget.doctorDetail.name;
    final service = Provider.of<CartService>(context).services[id];
    final servic = Provider.of<CartService>(context);
    List<ParlourSlotDetails> slots = widget.doctorDetail.slots;
    final gst1 = service != null ? service.subtotal * 0.08 ?? 0.0 : 0.0;
    final gst2 = service != null ? service.subtotal * 0.08 ?? 0.0 : 0.0;
    final time = service != null ? service.time : 0;
    final int minute = time % 60;
    final int hours = (time / 60).floor();
    double paymentValue = service?.subtotal?.toDouble() ?? 0.0 + gst1 + gst2;
    final startHr = slots.length != 0 ? int.tryParse(slots[0].fromHr) : 0;
    final startMin = slots.length != 0 ? int.tryParse(slots[0].fromMin) : 0;
    final endHr = slots.length != 0 ? int.tryParse(slots[0].toHr) : 0;
    final endMin = slots.length != 0 ? int.tryParse(slots[0].toMin) : 0; //

    final medicals = Provider.of<List<Medical>>(context);

    final selectedMedical = medicals.firstWhere(
        (element) => element.id == widget.clinicLocationAndDoctor.serviceUid);

    final selectedDoctor = selectedMedical.doctorDetails.firstWhere((element) =>
        element.name == widget.doctorDetail.name &&
        element.number == widget.doctorDetail.number);

    final bookedSlotsPerDay = selectedDoctor?.bookedSlotsPerDay ?? {};

    setState(() {
      int totalDuration = slotDuration + intervalDuration;
      int openTime = endMin + (endHr - startHr) * 60 - startMin;
      count = (openTime / totalDuration).floor();
      int reminder = openTime % totalDuration;
      if (reminder >= slotDuration) count++;
      print(count);
      rim = count % 2;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Slot Booking'),
        backgroundColor: Color(0xFF0F2735),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          UpperCardDoctorBooking(
              clinic: widget?.clinicLocationAndDoctor,
              doctor: widget?.doctorDetail,
              context: context),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         'This week',
          //         style: TextStyle(color: Colors.black, fontSize: 17.0),
          //         textAlign: TextAlign.right,
          //       ),
          //       Icon(
          //         Icons.calendar_today_outlined,
          //         color: Color(0xff5D5FEF),
          //       )
          //     ],
          //   ),
          // ),
          // SizedBox(height: 10.0),
          Container(
            padding: EdgeInsets.all(10.0),
            color: Color(0xFFFAFAFA),
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                dateSelected = true;
                setState(() {
                  if (_selectedDay == DateTime.utc(1989) ||
                      _selectedDay != selectedDay) changeDate = true;
                  _selectedDay = selectedDay;
                  _selectedDateForKey =
                      "${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year - 2000}";

                  _focusedDay = focusedDay; // update `_focusedDay` here as well
                });
                servic.updateDay(id, _selectedDay);
                print(service);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                defaultDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(6.0)),
                todayDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    border: Border.all(color: Color(0xff5D5FEF)),
                    borderRadius: BorderRadius.circular(6.0)),
                todayTextStyle: TextStyle(color: Colors.black),
                selectedTextStyle: TextStyle(color: Colors.black),
                defaultTextStyle: TextStyle(color: Colors.black),
                selectedDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.blue[100],
                    border: Border.all(color: Colors.blue[100]),
                    borderRadius: BorderRadius.circular(6.0)),
                withinRangeDecoration: BoxDecoration(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 40.0),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              'Select your slot ',
              style: TextStyle(color: Colors.black, fontSize: 17.0),
              textAlign: TextAlign.right,
            ),
          ),
//new ui widgets

          if (dateSelected)
            bookedSlotsPerDay[_selectedDateForKey] == null
                ? Container(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                    height: selectedDoctor.dividedSlots.length % 2 == 0
                        ? selectedDoctor.dividedSlots.length.toDouble() * 29.0
                        : selectedDoctor.dividedSlots.length.toDouble() * 29.0 +
                            29.0,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: selectedDoctor.dividedSlots?.length ?? 0,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: width * 0.4 / 40,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12),
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (selectedDoctor.dividedSlots[index].emp > 0) {
                                slotIndexSelected = index;
                                servic.updateTimeSlot(
                                    id,
                                    selectedDoctor.dividedSlots[index].time ??
                                        "");
                                slotSelected = true;
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: slotIndexSelected != index
                                        ? Colors.blue
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(6),
                                color: slotIndexSelected == index
                                    ? Color(0xff00A676)
                                    : Colors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                (Text(
                                    selectedDoctor.dividedSlots[index].time ??
                                        "",
                                    style: TextStyle(
                                        color: slotIndexSelected == index
                                            ? Colors.white
                                            : Color(0xff5D5FEF),
                                        fontSize: 12.0))),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${selectedDoctor.dividedSlots[index].emp}',
                                      style: TextStyle(
                                          color: slotIndexSelected == index
                                              ? Color(0xff00A676)
                                              : Colors.white,
                                          fontSize: 12.0),
                                    ),
                                  ),
                                  color: slotIndexSelected == index
                                      ? Colors.white
                                      : Color(0xff00A676),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                    height:
                        bookedSlotsPerDay[_selectedDateForKey].length % 2 == 0
                            ? bookedSlotsPerDay[_selectedDateForKey]
                                    .length
                                    .toDouble() *
                                29.0
                            : bookedSlotsPerDay[_selectedDateForKey]
                                        .length
                                        .toDouble() *
                                    29.0 +
                                29.0,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          bookedSlotsPerDay[_selectedDateForKey]?.length ?? 0,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: width * 0.4 / 40,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12),
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (bookedSlotsPerDay[_selectedDateForKey][index]
                                      ['emp'] >
                                  0) {
                                slotIndexSelected = index;
                                servic.updateTimeSlot(
                                    id,
                                    bookedSlotsPerDay[_selectedDateForKey]
                                            [index]['time'] ??
                                        "");
                                slotSelected = true;
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: slotIndexSelected != index
                                        ? Colors.blue
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(6),
                                color: slotIndexSelected == index
                                    ? Color(0xff00A676)
                                    : Colors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                (Text(
                                    bookedSlotsPerDay[_selectedDateForKey]
                                            [index]['time'] ??
                                        "",
                                    style: TextStyle(
                                        color: slotIndexSelected == index
                                            ? Colors.white
                                            : Color(0xff5D5FEF),
                                        fontSize: 12.0))),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${bookedSlotsPerDay[_selectedDateForKey][index]['emp']}',
                                      style: TextStyle(
                                          color: slotIndexSelected == index
                                              ? Color(0xff00A676)
                                              : Colors.white,
                                          fontSize: 12.0),
                                    ),
                                  ),
                                  color: slotIndexSelected == index
                                      ? Colors.white
                                      : Color(0xff00A676),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          SizedBox(height: 30),

//end of slot widgets

          // SizedBox(height: 15.0),
          // Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 0),
          //     child: Container(
          //         child: ListView.builder(
          //             shrinkWrap: true,
          //             physics: NeverScrollableScrollPhysics(),
          //             itemCount: (count ~/ 2) + rim,
          //             itemBuilder: (ctx, i) {
          //               if (i == 0) {
          //                 Min1 = startMin;
          //                 Hr1 = startHr > 12 ? startHr - 12 : startHr;
          //                 pm = startHr > 12 ? true : false;
          //                 tempCount = 0;
          //                 am_pm1[i] = startHr > 12 ? 'PM' : 'AM';
          //               } else {
          //                 Min1 = Min4 + intervalDuration;
          //                 Hr1 = Hr4 + (Min1 / 60).floor();
          //                 Min1 = Min1 % 60;
          //                 if (Hr1 == 12 || Hr1 > 12 || pm == true) {
          //                   am_pm1[i] = 'PM';
          //                   am_pm2[i] = 'PM';
          //                   am_pm3[i] = 'PM';
          //                   am_pm4[i] = 'PM';
          //                 }
          //                 if (Hr1 > 12) {
          //                   Hr1 = Hr1 - 12;
          //                 }
          //               }

          //               Min2 = Min1 + slotDuration;
          //               Hr2 = Hr1 + (Min2 / 60).floor();
          //               Min2 = Min2 % 60;
          //               if (Hr2 == 12 || Hr2 > 12 || pm == true) {
          //                 pm = true;
          //                 am_pm2[i] = 'PM';
          //                 am_pm3[i] = 'PM';
          //                 am_pm4[i] = 'PM';
          //               }
          //               if (Hr2 > 12) {
          //                 Hr2 = Hr2 - 12;
          //               }
          //               if (Min1 < 10)
          //                 lessMins1 = '0';
          //               else
          //                 lessMins1 = '';
          //               if (Min2 < 10)
          //                 lessMins2 = '0';
          //               else
          //                 lessMins2 = '';
          //               final _timeslot =
          //                   "$Hr1:$lessMins1$Min1 ${am_pm1[i]} - $Hr2:$lessMins2$Min2 ${am_pm2[i]}";
          //               tempCount++;
          //               print(tempCount);
          //               if (tempCount > count) {
          //                 stop1 = true;
          //                 stop2 = true;
          //               }

          //               Min3 = Min2 + intervalDuration;
          //               Hr3 = Hr2 + (Min3 / 60).floor();
          //               Min3 = Min3 % 60;
          //               if (Hr3 == 12 || Hr3 > 12 || pm == true) {
          //                 pm = true;

          //                 am_pm3[i] = 'PM';
          //                 am_pm4[i] = 'PM';
          //               }
          //               if (Hr3 > 12) {
          //                 Hr3 = Hr3 - 12;
          //               }

          //               Min4 = Min3 + slotDuration;
          //               Hr4 = Hr3 + (Min4 / 60).floor();
          //               Min4 = Min4 % 60;
          //               if (Hr4 == 12 || Hr4 > 12 || pm == true) {
          //                 pm = true;

          //                 am_pm4[i] = 'PM';
          //               }
          //               if (Hr4 > 12) {
          //                 Hr4 = Hr4 - 12;
          //               }
          //               if (Min3 < 10)
          //                 lessMins3 = '0';
          //               else
          //                 lessMins3 = '';
          //               if (Min4 < 10)
          //                 lessMins4 = '0';
          //               else
          //                 lessMins4 = '';

          //               final _timeslot1 =
          //                   "$Hr3:$lessMins3$Min3 ${am_pm3[i]} - $Hr4:$lessMins4$Min4 ${am_pm4[i]}";

          //               tempCount++;
          //               print(tempCount);
          //               if (tempCount > count) stop2 = true;

          //               final indx1 = i * 2;
          //               final indx2 = i * 2 + 1;
          //               // final int newEmployeeNumber = employeeNumbers - 1;

          //               if (changeDate == true) {
          //                 for (int x = 0; x < count; x++) {
          //                   // if (x != indx1)
          //                   slotButtons[x] = false;
          //                 }
          //               }

          //               return Row(
          //                 children: [
          //                   Padding(
          //                     padding: const EdgeInsets.all(10.0),
          //                     child: FlatButton(
          //                       padding: EdgeInsets.all(0.0),
          //                       onPressed: () {
          //                         if (dateSelected == false)
          //                           Fluttertoast.showToast(
          //                               msg: 'Please select a date',
          //                               backgroundColor: Color(0xff5D5FEF),
          //                               textColor: Colors.white,
          //                               toastLength: Toast.LENGTH_LONG);
          //                         setState(() {
          //                           slotSelected = !slotSelected;
          //                           if (_selectedDay == DateTime.utc(1989))
          //                             slotButtons[indx1] = false;
          //                           else {
          //                             slotButtons[indx1] = !slotButtons[indx1];
          //                           }
          //                           if (slotButtons[indx1] == true) {
          //                             for (int x = 0; x < count; x++) {
          //                               if (x != indx1) slotButtons[x] = false;
          //                             }
          //                             changeDate = false;
          //                             sl = _timeslot;
          //                           }
          //                         });
          //                         servic.updateTimeSlot(id, _timeslot);
          //                       },
          //                       child: slotButtons[indx1] == false
          //                           ? Container(
          //                               height: 50,
          //                               width: 160,
          //                               decoration: BoxDecoration(
          //                                   border:
          //                                       Border.all(color: Colors.blue),
          //                                   borderRadius:
          //                                       BorderRadius.circular(6.0)),
          //                               child: (Row(
          //                                 mainAxisAlignment:
          //                                     MainAxisAlignment.center,
          //                                 children: [
          //                                   Text(_timeslot,
          //                                       style: TextStyle(
          //                                           color: Color(0xff5D5FEF),
          //                                           fontSize: 12.0)),
          //                                 ],
          //                               )),
          //                             )
          //                           : Container(
          //                               height: 50,
          //                               width: 160,
          //                               decoration: BoxDecoration(
          //                                   borderRadius:
          //                                       BorderRadius.circular(6),
          //                                   color: Color(0xff00A676)),
          //                               child: Row(
          //                                 mainAxisAlignment:
          //                                     MainAxisAlignment.center,
          //                                 children: [
          //                                   (Text(_timeslot,
          //                                       style: TextStyle(
          //                                           color: Colors.white,
          //                                           fontSize: 12.0))),
          //                                 ],
          //                               ),
          //                             ),
          //                     ),
          //                   ),
          //                   stop2 == true && tempCount > count
          //                       ? SizedBox(width: 10)
          //                       : Padding(
          //                           padding: const EdgeInsets.all(10.0),
          //                           child: FlatButton(
          //                             padding: EdgeInsets.all(0.0),
          //                             onPressed: () {
          //                               if (dateSelected == false)
          //                                 Fluttertoast.showToast(
          //                                     msg: 'Please select a date',
          //                                     backgroundColor:
          //                                         Color(0xff5D5FEF),
          //                                     textColor: Colors.white,
          //                                     toastLength: Toast.LENGTH_LONG);
          //                               setState(() {
          //                                 slotSelected = !slotSelected;
          //                                 if (_selectedDay ==
          //                                     DateTime.utc(1989))
          //                                   slotButtons[indx2] = false;
          //                                 else {
          //                                   slotButtons[indx2] =
          //                                       !slotButtons[indx2];
          //                                 }
          //                                 if (slotButtons[indx2] == true) {
          //                                   for (int x = 0; x < count; x++) {
          //                                     if (x != indx2)
          //                                       slotButtons[x] = false;
          //                                   }
          //                                   changeDate = false;
          //                                   sl = _timeslot1;
          //                                 }
          //                               });
          //                               servic.updateTimeSlot(id, _timeslot1);
          //                             },
          //                             child: slotButtons[indx2] == false
          //                                 ? Container(
          //                                     height: 50,
          //                                     width: 160,
          //                                     decoration: BoxDecoration(
          //                                         border: Border.all(
          //                                             color: Colors.blue),
          //                                         borderRadius:
          //                                             BorderRadius.circular(
          //                                                 6.0)),
          //                                     child: (Row(
          //                                       mainAxisAlignment:
          //                                           MainAxisAlignment.center,
          //                                       children: [
          //                                         Text(_timeslot1,
          //                                             style: TextStyle(
          //                                                 color:
          //                                                     Color(0xff5D5FEF),
          //                                                 fontSize: 12.0)),
          //                                       ],
          //                                     )),
          //                                   )
          //                                 : Container(
          //                                     height: 50,
          //                                     width: 160,
          //                                     decoration: BoxDecoration(
          //                                         borderRadius:
          //                                             BorderRadius.circular(6),
          //                                         color: Color(0xff00A676)),
          //                                     child: Row(
          //                                       mainAxisAlignment:
          //                                           MainAxisAlignment.center,
          //                                       children: [
          //                                         (Text(_timeslot1,
          //                                             style: TextStyle(
          //                                                 color: Colors.white,
          //                                                 fontSize: 12.0))),
          //                                       ],
          //                                     ),
          //                                   ),
          //                           ),
          //                         )
          //                 ],
          //               );
          //             }))),
          LowerCardServiceTotal(
              service: service,
              id: id,
              clinicId: widget.clinicLocationAndDoctor.serviceUid,
              bookingConfirm: confirmBooking,
              bookedSlotsPerDay: bookedSlotsPerDay,
              slotIndexSelected: slotIndexSelected,
              selectedDateForKey: _selectedDateForKey,
              selectedDoctor: selectedDoctor,
              dateSelected: dateSelected,
              slotSelected: slotSelected,
              isChecked: isChecked,
              isSlotPage: true,
              showCheckBox: true,
              setIsChecked: setIsChecked)
        ]),
      ),
    );
  }
}
