import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'temperatureModel.dart';
import 'package:weatherapp/temperatureModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int temperature = 0;
  String city = 'city';
  int woied = 0;
  String weather = 'clear';
  String abbr = '';
  Future<List<temperatureModel>> fetchCity(String input) async {
    var url = Uri.parse(
        'https://www.metaweather.com/api/location/search/?query=$input');
    print(url);
    var response = await http.get(url);
    var responseBody = jsonDecode(response.body)['consolidated_weather'][0];
    print(responseBody);

    setState(() {
      temperature = responseBody['the_temp'].round();
      weather =
          responseBody['weather_state_name'].replaceAll('', '').toLowerCase;
      abbr = responseBody['weather_state_abbr'];
    });
    List<temperatureModel> list = [];
    for (var i in responseBody) {
      temperatureModel x = temperatureModel(
        applicable_date: i['applicable_date'],
        max_temp: i['max_temp'],
        min_temp: i['min_temp'],
        weather_state_abbr: i['weather_state_abbr'],
      );
      list.add(x);
    }
    return list;
  }

  Future<void> fetchTemperature() async {
    var url = Uri.parse('https://www.metaweather.com/api/location/$woied');
    var response = await http.get(url);
    var responseBody = jsonDecode(response.body)[0];
    setState(() {
      var min_temp = responseBody['woied'];
      var max_temp = responseBody['title'];
    });
  }

  Future<void> onTextSubmit(String input) async {
    await fetchCity(input);
    await fetchTemperature();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/$weather.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                    child: Image.network(
                  'https://www.metaweather.com/static/img/weather/png/$abbr.png',
                  //width: 600,
                  //height: 100,
                )),
                Center(
                    child: Text(
                  '$temperature',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 60,
                  ),
                )),
                Center(
                    child: Text(
                  '$city',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                  ),
                )),
                Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: TextField(
                          onSubmitted: (String input) {
                            onTextSubmit(input);
                          },
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                          decoration: InputDecoration(
                              hintText: 'Search in another city',
                              hintStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                                size: 23,
                              )),
                        ),
                      ),
                    ),
                    Container(
                      height: 178,
                      padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                      child: FutureBuilder(
                        future: fetchTemperature(),
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.data == null) {
                            return Text('');
                          }
                          else if (snapshot.hasData) {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                    color: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      height: 170,
                                      width: 120,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Date:${snapshot.data[index].applicable_date}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            'City:$city',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Image.network(
                                            'https://www.metaweather.com/static/img/weather/png/${snapshot.data[index].weather_state_abbr}.png',
                                          width: 50,
                                          ),
                                          Text(
                                            'Min:${snapshot.data[index].min_temp}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            'Max:${snapshot.data[index].max_temp}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                  },
    );
                          }
                          else{
                           return Text('');
                          }

                        }),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
