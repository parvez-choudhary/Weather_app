import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}



class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int temperature=0;
  String location="NewYork";
  int woeid= 44418;
  String weather="snow";
  String abbreviation='';
  String errorMessage='';

  String searchApiUrl ='gthttps://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl='https://www.metaweather.com/api/location/';

  @override
  initState(){
    super.initState();
    fetchlocation();
  }
    void fetchSearch(String input) async
  {
    try {
      var searchResults = await http.get(Uri.parse(searchApiUrl + input));
      var result = json.decode(searchResults.body)[0];
      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage='';
      });
    }
    catch(error){
      setState(() {
        errorMessage="sorry!!we don't have this location data";
      });
    }
  }
    void fetchlocation() async{
  var locationResult= await http.get(Uri.parse(locationApiUrl + woeid.toString()));
  var result = json.decode(locationResult.body);
  var  consolidatedweather= result["consolidated_weather"];
  var  data= consolidatedweather[0];



  setState(() {
    temperature= data["the_temp"].round();
    weather= data["weather_state_name"].replaceAll(' ','').toLowerCase();
    abbreviation=data["weather_state_abbr"];
  });
  }
  void onTextFieldSumbitted(String input) async {

     fetchlocation();
     fetchSearch(input);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      home: Container(

        decoration:  BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/$weather.png'),
              fit: BoxFit.cover
          ),
        ),
        child: temperature == 0?
         const Center( child: CircularProgressIndicator()):

        Scaffold(

          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Center(
                 child: Image.network(
                    'https://www.metaweather.com/static/img/weather/png/'+abbreviation+'.png',
                    width: 100,
                   height: 50,
                  ),
               ),

              Center(
                child: Text(

                    temperature.toString() + 'C',

                  style: const TextStyle(
                    color: Colors.white,fontSize: 60,
                  ),

                ),
              ),
              Text(
                location,
                style: const TextStyle(
                  color: Colors.white,fontSize: 60,
              ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 350,
                height: 100,

                //color: Colors.orange,
                child: TextField(
                  onSubmitted: (String input){
                    onTextFieldSumbitted(input);
                  },
                  style: const TextStyle(color: Colors.white,fontSize: 25),
                  decoration: const InputDecoration(
                    hintText: 'search another location here',
                    hintStyle: TextStyle(color: Colors.white,fontSize: 20),
                    prefixIcon: Icon(Icons.search,color: Colors.white,),
                  ),


                ),
              ),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.yellow,fontSize: 25,),

              )
            ],
          ),
        ),
      ),
    );
  }
}
