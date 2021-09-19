import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late Client httpClient;
  late Web3Client ethClient;
  final myAdress = "0xf6824D3D12470298E4302843D6056BD68B4b296f";
  double _value = 0.0;
  int myAmount = 0;
  var myData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpClient = Client();
    ethClient = Web3Client("https://rinkeby.infura.io/v3/1d5b3d78121343b8b9b9a1492c2b5949",httpClient);
    getBalance(myAdress);
  }

  Future<DeployedContract> loadContract() async{
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0xc97f88534400D8ffC9041A643a30b0d7A4CFC30b";
    final contract = DeployedContract(ContractAbi.fromJson(abi, "XCoin"), EthereumAddress.fromHex(contractAddress));

    return contract;
  }


  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(contract: contract, function: ethFunction, params: args);
    return result;
  } 


  Future<void> getBalance(String targetAddress) async{
    List<dynamic> result = await query("getBalance",[]);
    myData = result[0];
    setState(() { });
  }

  Future<String> withdrawCoin() async{
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("withdrawBalance",[bigAmount]);
    return response;
  }

  Future<String> depositCoin() async{
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("depositBalance",[bigAmount]);
    return response;
  }

  Future<String> submit(String functionName, List<dynamic> args) async{
    EthPrivateKey credential = EthPrivateKey.fromHex("12f9b1233afa51af06f77350db68b5c98a29ee7acc4bee2a3c50bbbffe298c56");
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(credential, Transaction.callContract(contract: contract, function: ethFunction, parameters: args), fetchChainIdFromNetworkId: true);
    return result;


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 50),
              margin: EdgeInsets.all(10),
              child: Text("${myData} \XCoin", style: TextStyle(fontSize: 40),),
            ),
            InkWell(
              child:Container(
                margin: EdgeInsets.only(top: 50),
                height: 40,
                width: 200,
                color: Colors.greenAccent,
                child: Center(child:Text("REFRESH", style: TextStyle(fontSize: 20),)),
              ),
              onTap: () {
                getBalance(myAdress);
              },
            ),
            Divider(height: 50,),
            SfSlider(
              min: 0.0,
              max: 10.0,
              value: _value,
              interval: 1,
              showTicks: true,
              showLabels: true,
              enableTooltip: true,
              minorTicksPerInterval: 1,
              onChanged: (dynamic value) {
                setState(() {
                  _value = value;
                  myAmount = value.round();
                });
              },
            ),
            InkWell(
              child: Container(
                margin: EdgeInsets.only(top: 50),
                height: 40,
                width: 200,
                color: Colors.blueAccent,
                child: Center(child:Text("DEPOSIT", style: TextStyle(fontSize: 20),)),
              ),
              onTap: () {depositCoin();},
            ),
            InkWell(
              child: Container(
                margin: EdgeInsets.only(top: 50),
                height: 40,
                width: 200,
                color: Colors.pinkAccent,
                child: Center(child:Text("WITHDRAW", style: TextStyle(fontSize: 20),)),
              ),
              onTap: () {withdrawCoin();},
            ),
             Container(
              padding: EdgeInsets.only(top: 150),
              child:  Center(child:Text("This is a basic UI.", style: TextStyle(fontSize: 30, color: Colors.grey),)),
            )
          ],
        ),
      ),
    );
  }
}
