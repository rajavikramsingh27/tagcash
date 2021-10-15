class Telcom {
  final int id;
  final String value;
  final String name;
  final String exttag;

  Telcom({this.id, this.value, this.name, this.exttag});
}

List<Telcom> telcoms = [
  Telcom(
    id: 0,
    value: 'GLOBE',
    name: 'GLOBE',
    exttag: 'LD',
  ),
  Telcom(
    id: 1,
    value: 'SMART',
    name: 'SMART',
    exttag: 'PLAN@',
  ),
  Telcom(
    id: 2,
    value: 'SUN',
    name: 'SUN',
    exttag: '@',
  ),
];
