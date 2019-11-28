import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:search_cep/models/result_cep.dart';
import 'package:search_cep/models/themes.dart';
import 'package:search_cep/services/custom_theme.dart';
import 'package:search_cep/services/via_cep_service.dart';
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _searchCepController = TextEditingController();
  bool _loading = false;
  bool _enableField = true;
  String _result;
  int _themeValue;
  ResultCep data = new ResultCep();
  var _keyForm = GlobalKey<FormState>();

  void _changeTheme(BuildContext buildContext, MyThemeKeys key) {
    CustomTheme.instanceOf(buildContext).changeTheme(key);
  }

  @override
  void initState() {
    super.initState();
    _themeValue = 0;
  }

  @override
  void dispose() {
    super.dispose();
    _searchCepController.clear();
  }

  void _setSelectRadio(int value) {
    setState(() {
      _themeValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultar CEP'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.wb_sunny),
            onPressed: () async {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Alterar Tema'),
                      content: Column(
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Text('Tema Normal'),
                                Radio(
                                  value: 1,
                                  groupValue: _themeValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _setSelectRadio(value);
                                      _changeTheme(context, MyThemeKeys.LIGHT);
                                      Navigator.of(context).pop();
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Text('Tema DARK'),
                                Radio(
                                  value: 2,
                                  groupValue: _themeValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _setSelectRadio(value);
                                      _changeTheme(context, MyThemeKeys.DARK);
                                      Navigator.of(context).pop();
                                    });
                                  },
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('CANCEL'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () {
                            setState(() {
                              if (_themeValue == 1) {
                                _changeTheme(context, MyThemeKeys.LIGHT);
                                Navigator.of(context).pop();
                              }
                              if (_themeValue == 2) {
                                _changeTheme(context, MyThemeKeys.DARK);
                                Navigator.of(context).pop();
                              }
                            });
                          },
                        ),
                      ],
                    );
                  });
            },
          )
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSearchCepTextField(),
            _buildSearchCepButton(),
            _buildFullResultForm(),
            IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                    Share.share(data.cep);
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCepTextField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: _searchCepController,
        decoration: InputDecoration(
          labelText: "Digite um CEP",
          labelStyle: TextStyle(fontSize: 18),
        ),
        validator: (text) {
          return text.length != 8 ? "Digite um CEP válido" : null;
        },
      ),
    );
  }

  Widget _buildFlushBar(e) {
    return Flushbar(
      title: "Erro!",
      message: e.toString(),
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      backgroundColor: Colors.redAccent,
      borderColor: Colors.black,
      duration: Duration(seconds: 5),
    )..show(context);
  }

  Widget _buildSearchCepButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: RaisedButton(
        onPressed: _searchCep,
        child: _loading ? _circularLoading() : Text('Consultar'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _searching(bool enable) {
    setState(() {
      _result = enable ? '' : _result;
      _loading = enable;
      _enableField = !enable;
    });
  }

  Widget _circularLoading() {
    return Container(
      height: 15.0,
      width: 15.0,
      child: CircularProgressIndicator(),
    );
  }

  Future _searchCep() async {
    _searching(true);

    final cep = _searchCepController.text;

    try {
      final resultCep = await ViaCepService.fetchCep(cep: cep);
      print(resultCep.localidade); // Exibindo somente a localidade no terminal

      setState(() {
        _result = resultCep.toJson();
        data = resultCep;
      });

      _searching(false);
    } catch (e) {
      _buildFlushBar(e);
    }
  }

  Widget _buildFullResultForm() {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('CEP: ${data.cep ?? ''}'),
            Text('LOGRADOURO: ${data.logradouro ?? ''}'),
            Text('COMPLEMENTO: ${data.complemento ?? ''}'),
            Text('BAIRRO: ${data.bairro ?? ''}'),
            Text('CIDADE: ${data.localidade ?? ''}'),
            Text('UF: ${data.uf ?? ''}'),
            Text('UNIDADE: ${data.unidade ?? ''}'),
            Text('IBGE: ${data.ibge ?? ''}'),
            Text('GIA: ${data.gia ?? ''}'),
          ],
        ));
  }
}
