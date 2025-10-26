// lib/screens/categories_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category_models.dart';
import '../utils/color_utils.dart';
//import '../widgets/pagination_bar.dart';
//import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _fts = TextEditingController();

  @override
  void initState() {
    super.initState();
    // inicijalno učitaj sve
    final provider = context.read<CategoryProvider>();
    Future.microtask(() => provider.load());
  }

  @override
  void dispose() {
    _fts.dispose();
    super.dispose();
  }

  // Future<String?> _pickHexColor(BuildContext context, String currentHex) async {
  //   Color current = tryParseHexColor(currentHex) ?? Colors.blue;
  //   Color selected = current;

  //   final ok = await showDialog<bool>(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text('Odaberi boju'),
  //       content: SingleChildScrollView(
  //         child: ColorPicker(
  //           pickerColor: current,
  //           onColorChanged: (c) => selected = c,
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Odustani'),
  //         ),
  //         FilledButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: const Text('Potvrdi'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (ok == true) return colorToHex6(selected);
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoryProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // FILTER BAR
        // Wrap(
        //   spacing: 12,
        //   runSpacing: 8,
        //   crossAxisAlignment: WrapCrossAlignment.center,
        //   children: [
        //     SizedBox(
        //       width: 260,
        //       child: TextField(
        //         controller: _fts,
        //         decoration: const InputDecoration(
        //           labelText: 'Pretraga po nazivu',
        //           prefixIcon: Icon(Icons.search),
        //         ),
        //         onSubmitted: (_) {
        //           vm.fts = _fts.text;
        //           vm.load();
        //         },
        //       ),
        //     ),
        //     DropdownButton<bool?>(
        //       value: vm.active,
        //       items: const [
        //         DropdownMenuItem(value: null, child: Text('Sve')),
        //         DropdownMenuItem(value: true, child: Text('Aktivne')),
        //         DropdownMenuItem(value: false, child: Text('Neaktivne')),
        //       ],
        //       onChanged: (v) {
        //         vm.active = v;
        //         vm.load();
        //       },
        //     ),
        //     FilledButton.icon(
        //       onPressed: () {
        //         vm.fts = _fts.text;
        //         vm.load();
        //       },
        //       icon: const Icon(Icons.search),
        //       label: const Text('Traži'),
        //     ),
        //     const SizedBox(width: 16),
        //     OutlinedButton.icon(
        //       //onPressed: () => _openCreateDialog(context),
        //       icon: const Icon(Icons.add),
        //       label: const Text('Nova kategorija'),
        //       onPressed: () => Navigator.pushNamed(context, '/categories/new'),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 12),

        // === HEADER ===
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 12),
        //   child: Row(
        //     children: [
        //       Text(
        //         'Kategorije',
        //         style: Theme.of(context).textTheme.titleLarge?.copyWith(
        //           fontSize: 22,
        //           fontWeight: FontWeight.w700,
        //         ),
        //       ),
        //       const Spacer(),
        //       OutlinedButton.icon(
        //         icon: const Icon(Icons.add),
        //         label: const Text('Nova kategorija'),
        //         onPressed: () =>
        //             Navigator.pushNamed(context, '/categories/new'),
        //         style: OutlinedButton.styleFrom(
        //           minimumSize: const Size(140, 40),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        // // === FILTER BAR ===
        // Row(
        //   children: [
        //     // Search
        //     Expanded(
        //       child: TextField(
        //         controller: _fts,
        //         decoration: const InputDecoration(
        //           labelText: 'Pretraga po nazivu',
        //           prefixIcon: Icon(Icons.search),
        //         ),
        //         onSubmitted: (_) {
        //           vm.fts = _fts.text;
        //           vm.load();
        //         },
        //       ),
        //     ),
        //     const SizedBox(width: 12),

        //     // Status (Sve/Aktivne/Neaktivne) kao outlined polje
        //     SizedBox(
        //       width: 160,
        //       child: DropdownButtonFormField<bool?>(
        //         value: vm.active,
        //         decoration: const InputDecoration(labelText: 'Status'),
        //         items: const [
        //           DropdownMenuItem(value: null, child: Text('Sve')),
        //           DropdownMenuItem(value: true, child: Text('Aktivne')),
        //           DropdownMenuItem(value: false, child: Text('Neaktivne')),
        //         ],
        //         onChanged: (v) {
        //           vm.active = v;
        //           vm.load();
        //         },
        //       ),
        //     ),
        //     const SizedBox(width: 12),

        //     // Traži
        //     FilledButton.icon(
        //       onPressed: () {
        //         vm.fts = _fts.text;
        //         vm.load();
        //       },
        //       icon: const Icon(Icons.search),
        //       label: const Text('Traži'),
        //       style: FilledButton.styleFrom(
        //         minimumSize: const Size(100, 40),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(12),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 12),

        // NASLOV
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Kategorije',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // TOOLBAR bez okvira
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // uži search
              Flexible(
                flex: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: TextField(
                    controller: _fts,
                    decoration: const InputDecoration(
                      labelText: 'Pretraga po nazivu',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) {
                      vm.fts = _fts.text;
                      vm.load();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Status
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<bool?>(
                  initialValue: vm.active,
                  decoration: const InputDecoration(labelText: 'Status'),
                  onChanged: (v) {
                    vm.active = v;
                    vm.load();
                  },
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Sve')),
                    DropdownMenuItem(value: true, child: Text('Aktivne')),
                    DropdownMenuItem(value: false, child: Text('Neaktivne')),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Traži
              FilledButton.icon(
                onPressed: () {
                  vm.fts = _fts.text;
                  vm.load();
                },
                icon: const Icon(Icons.search),
                label: const Text('Traži'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Nova kategorija – desno, bez okvira oko reda
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Nova kategorija'),
            onPressed: () => Navigator.pushNamed(context, '/categories/new'),
          ),
        ),

        const SizedBox(height: 8),

        // TABLICA
        Expanded(
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vm.error != null
              ? Center(child: Text(vm.error!))
              : _CategoryTable(
                  items: vm.items,
                  onToggle: (id) => vm.toggle(id),
                  // onDelete: (id) async {
                  //   final ok = await _confirm(context, 'Obrisati kategoriju?');
                  //   if (ok) vm.remove(id);
                  // },
                  onDelete: (id) async {
                    final ok = await _confirm(context, 'Obrisati kategoriju?');
                    if (!ok) return;
                    try {
                      await vm.remove(id); // zove API i ažurira listu
                    } catch (e) {
                      // prikaži snackbar ili dialog sa porukom
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Brisanje nije uspjelo: $e')),
                        );
                      }
                    }
                  },
                  //onEdit: (c) => _openEditDialog(context, c),
                  onEdit: (c) {
                    Navigator.pushNamed(
                      context,
                      '/categories/edit',
                      arguments: c,
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Prikaz ${vm.totalCount == 0 ? 0 : vm.page * vm.pageSize + 1}'
                '–${vm.page * vm.pageSize + vm.items.length} od ${vm.totalCount}',
              ),
              const SizedBox(width: 16),
              IconButton(
                tooltip: 'Prethodna',
                onPressed: vm.page > 0 ? vm.prevPage : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('${vm.page + 1}/${vm.lastPage + 1}'),
              IconButton(
                tooltip: 'Sljedeća',
                onPressed: (vm.page < vm.lastPage) ? vm.nextPage : null,
                icon: const Icon(Icons.chevron_right),
              ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: vm.pageSize,
                items: const [
                  DropdownMenuItem(value: 10, child: Text('10')),
                  DropdownMenuItem(value: 20, child: Text('20')),
                  DropdownMenuItem(value: 50, child: Text('50')),
                ],
                onChanged: (v) {
                  if (v != null) vm.setPageSize(v);
                },
              ),
            ],
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 12),
        //   child: PaginationBar(
        //     page: vm.page,
        //     pageSize: vm.pageSize,
        //     totalCount: vm.totalCount,
        //     visibleCount: vm.items.length, // isto kao prije
        //     onPrev: vm.prevPage,
        //     onNext: vm.nextPage,
        //     onPageSize: (v) => vm.setPageSize(v),
        //   ),
        // ),
      ],
    );
  }

  // Future<void> _openCreateDialog(BuildContext context) async {
  //   final name = TextEditingController();
  //   final ord = TextEditingController();
  //   final color = TextEditingController(text: '#3B82F6'); // default plava
  //   bool active = true;

  //   final provider = context.read<CategoryProvider>(); //
  //   final ok = await showDialog<bool>(
  //     context: context,
  //     builder: (_) => StatefulBuilder(
  //       builder: (_, setS) => AlertDialog(
  //         title: const Text('Nova kategorija'),
  //         content: SizedBox(
  //           width: 360,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextField(
  //                 controller: name,
  //                 decoration: const InputDecoration(labelText: 'Naziv'),
  //               ),
  //               const SizedBox(height: 8),
  //               TextField(
  //                 controller: ord,
  //                 decoration: const InputDecoration(labelText: 'Redni broj'),
  //                 keyboardType: TextInputType.number,
  //               ),
  //               const SizedBox(height: 8),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: TextField(
  //                       controller: color,
  //                       readOnly: true,
  //                       decoration: const InputDecoration(labelText: 'Boja'),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 8),
  //                   OutlinedButton.icon(
  //                     icon: const Icon(Icons.color_lens),
  //                     label: const Text('Izaberi'),
  //                     onPressed: () async {
  //                       final picked = await _pickHexColor(context, color.text);
  //                       if (picked != null) {
  //                         setS(() => color.text = picked);
  //                       }
  //                     },
  //                   ),
  //                 ],
  //               ),
  //               // NOVO za aktivnost kreiranje kategorije
  //               const SizedBox(height: 8),
  //               // SwitchListTile(
  //               //   value: active,
  //               //   onChanged: (v) => setS(
  //               //     () => active = v,
  //               //   ), // ako koristiš StatefulBuilder ili Statefull dialog
  //               //   title: const Text('Aktivna'),
  //               // ),
  //               Align(
  //                 alignment: Alignment.centerLeft,
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     const Text('Aktivna'),
  //                     const SizedBox(width: 10),
  //                     Checkbox(
  //                       value: active,
  //                       onChanged: (v) => setS(() => active = v ?? false),
  //                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                       visualDensity: VisualDensity.compact,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context, false),
  //             child: const Text('Odustani'),
  //           ),
  //           FilledButton(
  //             onPressed: () => Navigator.pop(context, true),
  //             child: const Text('Snimi'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );

  //   if (ok == true) {
  //     final r = CreateCategoryRequest(
  //       name: name.text.trim(),
  //       ordinalNumber: int.tryParse(ord.text) ?? 0,
  //       color: color.text.trim(),
  //       active: active,
  //     );
  //     await provider.create(r);
  //   }
  // }

  // Future<void> _openEditDialog(BuildContext context, CategoryDto c) async {
  //   final name = TextEditingController(text: c.name);
  //   final ord = TextEditingController(text: c.ordinalNumber.toString());
  //   final color = TextEditingController(text: c.color);
  //   bool active = c.active;

  //   final provider = context.read<CategoryProvider>();
  //   final ok = await showDialog<bool>(
  //     context: context,
  //     builder: (_) => StatefulBuilder(
  //       builder: (_, setS) => AlertDialog(
  //         title: const Text('Uredi kategoriju'),
  //         content: SizedBox(
  //           width: 360,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextField(
  //                 controller: name,
  //                 decoration: const InputDecoration(labelText: 'Naziv'),
  //               ),
  //               const SizedBox(height: 8),
  //               TextField(
  //                 controller: ord,
  //                 decoration: const InputDecoration(labelText: 'R.br.'),
  //                 keyboardType: TextInputType.number,
  //               ),
  //               const SizedBox(height: 8),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: TextField(
  //                       controller: color,
  //                       readOnly: true,
  //                       decoration: const InputDecoration(labelText: 'Boja'),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 8),
  //                   OutlinedButton.icon(
  //                     icon: const Icon(Icons.color_lens),
  //                     label: const Text('Izaberi'),
  //                     onPressed: () async {
  //                       final picked = await _pickHexColor(context, color.text);
  //                       if (picked != null) {
  //                         setS(
  //                           () => color.text = picked,
  //                         ); // koristi setS iz StatefulBuilder-a
  //                       }
  //                     },
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 8),
  //               SwitchListTile(
  //                 value: active,
  //                 onChanged: (v) => setS(() => active = v),
  //                 title: const Text('Aktivna'),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context, false),
  //             child: const Text('Odustani'),
  //           ),
  //           FilledButton(
  //             onPressed: () => Navigator.pop(context, true),
  //             child: const Text('Snimi'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );

  //   if (ok == true) {
  //     final r = UpdateCategoryRequest(
  //       name: name.text.trim(),
  //       ordinalNumber: int.tryParse(ord.text) ?? 0,
  //       color: color.text.trim(),
  //       active: active,
  //     );
  //     await provider.update(c.id, r);
  //   }
  // }

  //   Future<bool> _confirm(BuildContext context, String msg) async {
  //     final ok = await showDialog<bool>(
  //       context: context,
  //       builder: (_) => AlertDialog(
  //         content: Text(msg),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context, false),
  //             child: const Text('Ne'),
  //           ),
  //           FilledButton(
  //             onPressed: () => Navigator.pop(context, true),
  //             child: const Text('Da'),
  //           ),
  //         ],
  //       ),
  //     );
  //     return ok == true;
  //   }
  // }

  // Malo ospirnije tj ako API padne da dodje ispis da brisanje nije uspjelo
  Future<bool> _confirm(BuildContext context, String msg) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Potvrda'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ne'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Da'),
          ),
        ],
      ),
    );
    return ok == true;
  }
}

class _CategoryTable extends StatelessWidget {
  final List<CategoryDto> items;
  final void Function(int id) onToggle;
  final void Function(int id) onDelete;
  final void Function(CategoryDto c) onEdit;

  const _CategoryTable({
    required this.items,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Redni broj')),
            DataColumn(label: Text('Naziv')),
            DataColumn(label: Text('Boja')),
            DataColumn(label: Text('Aktivna?')),
            DataColumn(label: Text('Akcije')),
          ],
          rows: items.map((c) {
            return DataRow(
              cells: [
                DataCell(Text(c.ordinalNumber.toString())),
                DataCell(Text(c.name)),
                DataCell(_ColorDot(hex: c.color)),
                DataCell(_ActiveChip(active: c.active)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => onEdit(c),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        tooltip: c.active ? 'Deaktiviraj' : 'Aktiviraj',
                        onPressed: () => onToggle(c.id),
                        icon: Icon(
                          c.active ? Icons.toggle_on : Icons.toggle_off,
                          size: 30, // malo veće da vizualno “nosi” status
                          color: c.active
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      IconButton(
                        onPressed: () => onDelete(c.id),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// class _ColorDot extends StatelessWidget {
//   final String hex;
//   const _ColorDot({required this.hex});

//   @override
//   Widget build(BuildContext context) {
//     Color? col;
//     try {
//       col = Color(int.parse(hex.replaceFirst('#', '0xff')));
//     } catch (_) {}
//     col ??= Theme.of(context).colorScheme.primary;
//     return Row(
//       children: [
//         Container(
//           width: 16,
//           height: 16,
//           decoration: BoxDecoration(color: col, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 8),
//         Text(hex),
//       ],
//     );
//   }
// }
class _ColorDot extends StatelessWidget {
  final String hex;
  const _ColorDot({required this.hex});

  static const double _size = 16;
  static const bool _showTooltip = true;

  @override
  Widget build(BuildContext context) {
    final col = tryParseHexColor(hex) ?? Theme.of(context).colorScheme.primary;

    final dot = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: col,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
    );

    return _showTooltip ? Tooltip(message: hex, child: dot) : dot;
  }
}

class _ActiveChip extends StatelessWidget {
  final bool active;
  const _ActiveChip({required this.active});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? cs.primaryContainer : cs.errorContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(active ? 'DA' : 'NE'),
    );
  }
}
