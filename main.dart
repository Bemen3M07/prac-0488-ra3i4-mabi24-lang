import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Moto {
  final String marcaModelo;
  final double fuelTankLiters;
  final double consumptionL100;

  Moto({
    required this.marcaModelo,
    required this.fuelTankLiters,
    required this.consumptionL100,
  });
}

final List<Moto> motos = [
  Moto(marcaModelo: 'Honda PCX 125', fuelTankLiters: 8.0, consumptionL100: 2.1),
  Moto(marcaModelo: 'Yamaha NMAX 125', fuelTankLiters: 7.1, consumptionL100: 2.2),
  Moto(marcaModelo: 'Kymco Agility City 125', fuelTankLiters: 7.0, consumptionL100: 2.5),
  Moto(marcaModelo: 'Piaggio Liberty 125', fuelTankLiters: 6.0, consumptionL100: 2.3),
  Moto(marcaModelo: 'Sym Symphony 125', fuelTankLiters: 5.5, consumptionL100: 2.4),
  Moto(marcaModelo: 'Vespa Primavera 125', fuelTankLiters: 8.0, consumptionL100: 2.8),
  Moto(marcaModelo: 'Kawasaki J125', fuelTankLiters: 11.0, consumptionL100: 3.5),
  Moto(marcaModelo: 'Peugeot Pulsion 125', fuelTankLiters: 12.0, consumptionL100: 3.0),
];


class MotoProvider extends ChangeNotifier {
  Moto? _motoSeleccionada;

  Moto? get motoSeleccionada => _motoSeleccionada;

  void seleccionar(Moto moto) {
    _motoSeleccionada = moto;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MotoProvider(),
      child: const MaterialApp(
        //quito la banderita esa terrible
        debugShowCheckedModeBanner: false,
        home: PaginaSeleccionMotos(),
      ),
    ),
  );
}
// Clase statefull con el correspondiente createState.
class PaginaSeleccionMotos extends StatefulWidget {
  const PaginaSeleccionMotos({super.key});
  @override
  State<PaginaSeleccionMotos> createState() => _PaginaSeleccionMotosState();
}

class _PaginaSeleccionMotosState extends State<PaginaSeleccionMotos> {
  Moto? _motoChula;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(title: const Text('Motos APP')),
        
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children: [
              Text('Selecciona una moto..',style: TextStyle(fontSize: 20)),
              // Dropdown
              DropdownButton<Moto>(
                
                padding: EdgeInsets.all(12),
                value: _motoChula,
                hint: const Text('Selecciona...'),
                items: motos.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m.marcaModelo));
                }).toList(),
                onChanged: (moto) {
                  setState(() {
                    _motoChula = moto;
                  });
                },
              ),
              const SizedBox(height: 20),
              // Info de la moto seleccionada
              if (_motoChula != null) ...[
                Text('Model: ${_motoChula!.marcaModelo}', style: TextStyle(fontSize: 20)),
                Text('Dipòsit: ${_motoChula!.fuelTankLiters} L', style: TextStyle(fontSize: 20)),
                Text('Consum: ${_motoChula!.consumptionL100} L/100km', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                
                // Boton salto a la calculadora
                ElevatedButton(
                  onPressed: () {
                    
                    context.read<MotoProvider>().seleccionar(_motoChula!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaginaCalcul()),
                    );
                  },
                  child: const Text('Calcular', style: TextStyle(fontSize: 20)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


/* ########## PAGINA DE LOS CALCULOSSS ################ */

class PaginaCalcul extends StatefulWidget {
  const PaginaCalcul({super.key});
  @override
  State<PaginaCalcul> createState() => _PaginaCalculState();
}

class _PaginaCalculState extends State<PaginaCalcul> {
  final _kmInicialController = TextEditingController();
  final _kmActualController = TextEditingController();
  double? _resultat;

  @override
  void dispose() {
    _kmInicialController.dispose();
    _kmActualController.dispose();
    super.dispose();
  }

  void _calcular() {
    final moto = context.read<MotoProvider>().motoSeleccionada!;
    final kmInicial = double.tryParse(_kmInicialController.text) ?? 0;
    final kmActual = double.tryParse(_kmActualController.text) ?? 0;

    final autonomia = (moto.fuelTankLiters / moto.consumptionL100) * 100;
    
    // Km recorreguts
    final kmRecorreguts = kmActual - kmInicial;
    // Km restants
    final restants = autonomia - kmRecorreguts;

    setState(() {
      _resultat = restants > 0 ? restants : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final moto = context.watch<MotoProvider>().motoSeleccionada!;

    return Scaffold(
      appBar: AppBar(title: Text(moto.marcaModelo)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Diposit: ${moto.fuelTankLiters} L', style: TextStyle(fontSize: 20)),
              Text('Consum: ${moto.consumptionL100} L/100km', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20, width: 80,),
              TextField(
                controller: _kmInicialController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Km al omplir dipòsit'),
              ),
              TextField(
                
                controller: _kmActualController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Km actuals'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calcular,
                child: const Text('Calcular', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 20),
              if (_resultat != null)
                Text(
                  'Pots fer: ${_resultat!.toStringAsFixed(1)} km',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


