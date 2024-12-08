import 'package:flutter/material.dart';
// import 'package:librarymanage/AdditionalScreen/profile.dart';
import 'package:librarymanage/Elements/booknames.dart';
import 'package:librarymanage/Elements/userinformation.dart';
import 'package:librarymanage/main.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'screenElements.dart';

class PdfViewScreen extends StatefulWidget {
  final Books readbook;
  const PdfViewScreen({super.key, required this.readbook});

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  late PdfViewerController _pdfViewerController;
  @override
  void initState(){
    _pdfViewerController = PdfViewerController();
    super.initState();
}
  String _pdfImport() {
    try{
        final pdf_url = supabase.storage.from('pdf').getPublicUrl('${widget.readbook.book_id}.pdf');
        return pdf_url;
    } catch(error){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unexpected error: ${error.toString()}')));
      return '';
    }
  }
  // int _nextPage(){
  //   if(widget.readbook.status< widget.readbook.total_pages){
  //       widget.readbook.status++;
  //   }
  //   return widget.readbook.status;
  // }
  //   int _previousPage(){
  //   if(widget.readbook.status <= widget.readbook.total_pages && widget.readbook.status>1){
  //       widget.readbook.status--;
  //   }
  //    return widget.readbook.status;
  // }
  @override
  Widget build(BuildContext context) {
    final currentUser =Provider.of<Users>(context);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult:(didPop, int? result) async {
        if(didPop){
          return;
        }
        result = widget.readbook.status;
        Navigator.pop(context,result);
        },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.readbook.book_name, style: ScreenWidget().titlestyle),
          leading: IconButton(onPressed: () async{
            await supabase.rpc('update_book_status', params: {
            'id': currentUser.user_id,
            'book_id': widget.readbook.book_id,
            'new_status': widget.readbook.status
            });
            Navigator.maybePop(context, widget.readbook.status);
          }, icon: const Icon(Icons.arrow_back)),
        ),
        body: Column( 
          children:[
            Expanded(
              child: SfPdfViewer.network(
                      _pdfImport(),
                      pageLayoutMode: PdfPageLayoutMode.single,
                      initialPageNumber: widget.readbook.status,
                      controller: _pdfViewerController,
                      canShowScrollHead: false,
                      onPageChanged: (details) {
                        setState(() {
                          widget.readbook.status= details.newPageNumber;
                        });
                      },
                      )
      
              // child: FutureBuilder(
              //   future: _pdfImport(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return const CircularProgressIndicator();
              //     } else if (snapshot.hasError) {
              //       return Text('Error: ${snapshot.error}');
              //     } else if (snapshot.hasData) {
              //       return SfPdfViewer.network(
              //         snapshot.data!,
              //         pageLayoutMode: PdfPageLayoutMode.single,
              //         initialPageNumber: widget.readbook.status,
              //         controller: _pdfViewerController,
              //         canShowScrollHead: false,
              //        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              //         setState(() {
              //           widget.readbook.status=_pdfViewerController.pageNumber;
              //           widget.readbook.status= _pdfViewerController.pageCount;
              //         });
              //        },
              //       );
              //     } else {
              //       return const Text('No data found');
              //     }
              //   }),
            ),
            Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListTile(
                    title: const Icon(Icons.arrow_back),
                    onTap: (){
                     _pdfViewerController.previousPage();
                      setState(() {
                        widget.readbook.status = _pdfViewerController.pageNumber;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Page ${widget.readbook.status} of ${widget.readbook.total_pages}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Icon(Icons.arrow_forward),
                    onTap: (){
                    _pdfViewerController.nextPage();
                      setState(() {
                        widget.readbook.status = _pdfViewerController.pageNumber;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          ] 
        ),
      ),
    );
  }
}