// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'package:photo_view/photo_view.dart';
// import 'auth/auth_bloc/auth_bloc.dart';
// import 'auth/auth_bloc/auth_event.dart';
//
// class FileListScreen extends StatelessWidget {
//   const FileListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('File List'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
//             },
//           ),
//         ],
//
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('files').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             print("Error in StreamBuilder: ${snapshot.error}");
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             print("No data in snapshot");
//             return const Center(child: Text('No files found'));
//           }
//
//           print("Number of documents: ${snapshot.data!.docs.length}");
//
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 1,
//                 mainAxisSpacing: 20,
//                 crossAxisSpacing: 20
//               ),
//               itemCount: snapshot.data!.docs.length,
//               itemBuilder: (context, index) {
//                 var doc = snapshot.data!.docs[index];
//                 var data = doc.data() as Map<String, dynamic>;
//                 print("Document data: $data");
//
//                 String fileName = data['fileName'] ?? 'Unnamed File';
//                 String fileType = inferFileType(fileName);
//
//                 return GridTile(
//                   footer: GridTileBar(
//                     backgroundColor: Colors.black54,
//                     title: Text(fileName),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Email: ${data['userEmail'] ?? 'N/A'}'),
//                         Text(formatTimestamp(data['timestamp'])),
//                       ],
//                     ),
//                   ),
//                   child: InkResponse(
//                     enableFeedback: true,
//                     onTap: () {
//                       handleFilePreview(context, fileType, data['downloadUrl']);
//                     },
//                     child: buildFilePreview(fileType, data['downloadUrl']),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   String inferFileType(String fileName) {
//     if (fileName.toLowerCase().endsWith('.pdf')) {
//       return 'pdf';
//     } else if (fileName.toLowerCase().endsWith('.jpg') ||
//         fileName.toLowerCase().endsWith('.jpeg') ||
//         fileName.toLowerCase().endsWith('.png') ||
//         fileName.toLowerCase().endsWith('.gif')) {
//       return 'image';
//     } else {
//       return 'unknown';
//     }
//   }
//
//   Widget buildFilePreview(String fileType, String? downloadUrl) {
//     print("Building preview for - File Type: $fileType, Download URL: $downloadUrl");
//
//     if (downloadUrl == null) {
//       return Center(
//         child: Text(
//           'Download URL missing',
//           style: TextStyle(color: Colors.red),
//         ),
//       );
//     }
//
//     if (fileType == 'image') {
//       return Image.network(
//         downloadUrl,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           print("Error loading image: $error");
//           return Center(child: Text('Error loading image'));
//         },
//       );
//     } else if (fileType == 'pdf') {
//       return Center(
//         child: Icon(
//           Icons.picture_as_pdf,
//           size: 50,
//           color: Colors.red,
//         ),
//       );
//     } else {
//       return Center(
//         child: Icon(
//           Icons.insert_drive_file,
//           size: 50,
//           color: Colors.grey,
//         ),
//       );
//     }
//   }
//
//   void handleFilePreview(BuildContext context, String fileType, String? downloadUrl) {
//     print("Handling preview for - File Type: $fileType, Download URL: $downloadUrl");
//     if (fileType == 'pdf' && downloadUrl != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PDFViewerPage(pdfUrl: downloadUrl),
//         ),
//       );
//     } else if (fileType == 'image' && downloadUrl != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ImageViewerPage(imageUrl: downloadUrl),
//         ),
//       );
//     } else {
//       print("Unsupported file type or missing download URL");
//     }
//   }
//
//   String formatTimestamp(dynamic timestamp) {
//     if (timestamp == null) return 'N/A';
//     if (timestamp is Timestamp) {
//       return DateFormat.yMd().add_jm().format(timestamp.toDate());
//     }
//     return timestamp.toString();
//   }
// }
//
// class PDFViewerPage extends StatelessWidget {
//   final String pdfUrl;
//
//   const PDFViewerPage({super.key, required this.pdfUrl});
//
//   Future<String> get localPath async {
//     final directory = await getApplicationDocumentsDirectory();
//     return directory.path;
//   }
//
//   Future<File> get localFile async {
//     final path = await localPath;
//     return File('$path/temp.pdf');
//   }
//
//   Future<File> downloadFile() async {
//     try {
//       final response = await http.get(Uri.parse(pdfUrl));
//       final file = await localFile;
//       return file.writeAsBytes(response.bodyBytes);
//     } catch (e) {
//       print("Error downloading PDF: $e");
//       rethrow;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('PDF Viewer'),
//       ),
//       body: FutureBuilder<File>(
//         future: downloadFile(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (snapshot.hasError) {
//               return Center(
//                 child: Text('Error: ${snapshot.error}'),
//               );
//             }
//             return PDFView(
//               filePath: snapshot.data!.path,
//               onError: (error) {
//                 print("Error loading PDF: $error");
//               },
//             );
//           } else {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
//
// class ImageViewerPage extends StatelessWidget {
//   final String imageUrl;
//
//   const ImageViewerPage({super.key, required this.imageUrl});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Image Viewer', style: TextStyle(color: Colors.white),),
//         backgroundColor: Colors.black,
//       ),
//       body: PhotoView(
//         imageProvider: NetworkImage(imageUrl),
//         minScale: PhotoViewComputedScale.contained,
//         maxScale: PhotoViewComputedScale.covered * 2,
//         initialScale: PhotoViewComputedScale.contained,
//         heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';

import 'auth/auth_bloc/auth_bloc.dart';
import 'auth/auth_bloc/auth_event.dart';

class FileListScreen extends StatelessWidget {
  const FileListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('files').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Error in StreamBuilder: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print("No data in snapshot");
            return const Center(child: Text('No files found'));
          }

          print("Number of documents: ${snapshot.data!.docs.length}");

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
                print("Document data: $data");

                String fileName = data['fileName'] ?? 'Unnamed File';
                String fileType = inferFileType(fileName);

                return Stack(
                  children: [
                    GridTile(
                      footer: GridTileBar(
                        backgroundColor: Colors.black54,
                        title: Text(fileName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${data['userEmail'] ?? 'N/A'}'),
                            Text(formatTimestamp(data['timestamp'])),
                          ],
                        ),
                      ),
                      child: InkResponse(
                        enableFeedback: true,
                        onTap: () {
                          handleFilePreview(context, fileType, data['downloadUrl']);
                        },
                        child: buildFilePreview(fileType, data['downloadUrl']),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteFile(context, doc.id),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  void deleteFile(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete File'),
          content: Text('Are you sure you want to delete this file?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('files').doc(docId).delete();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('File deleted successfully')),
                  );
                } catch (e) {
                  print('Error deleting file: $e');
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting file')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  String inferFileType(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return 'pdf';
    } else if (fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png') ||
        fileName.toLowerCase().endsWith('.gif')) {
      return 'image';
    } else {
      return 'unknown';
    }
  }

  Widget buildFilePreview(String fileType, String? downloadUrl) {
    print("Building preview for - File Type: $fileType, Download URL: $downloadUrl");

    if (downloadUrl == null) {
      return Center(
        child: Text(
          'Download URL missing',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    if (fileType == 'image') {
      return Image.network(
        downloadUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image: $error");
          return Center(child: Text('Error loading image'));
        },
      );
    } else if (fileType == 'pdf') {
      return Center(
        child: Icon(
          Icons.picture_as_pdf,
          size: 50,
          color: Colors.red,
        ),
      );
    } else {
      return Center(
        child: Icon(
          Icons.insert_drive_file,
          size: 50,
          color: Colors.grey,
        ),
      );
    }
  }

  void handleFilePreview(BuildContext context, String fileType, String? downloadUrl) {
    print("Handling preview for - File Type: $fileType, Download URL: $downloadUrl");
    if (fileType == 'pdf' && downloadUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(pdfUrl: downloadUrl),
        ),
      );
    } else if (fileType == 'image' && downloadUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerPage(imageUrl: downloadUrl),
        ),
      );
    } else {
      print("Unsupported file type or missing download URL");
    }
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      return DateFormat.yMd().add_jm().format(timestamp.toDate());
    }
    return timestamp.toString();
  }
}

class PDFViewerPage extends StatelessWidget {
  final String pdfUrl;

  const PDFViewerPage({super.key, required this.pdfUrl});

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/temp.pdf');
  }

  Future<File> downloadFile() async {
    try {
      final response = await http.get(Uri.parse(pdfUrl));
      final file = await localFile;
      return file.writeAsBytes(response.bodyBytes);
    } catch (e) {
      print("Error downloading PDF: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: FutureBuilder<File>(
        future: downloadFile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            return PDFView(
              filePath: snapshot.data!.path,
              onError: (error) {
                print("Error loading PDF: $error");
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class ImageViewerPage extends StatelessWidget {
  final String imageUrl;

  const ImageViewerPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Viewer', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        initialScale: PhotoViewComputedScale.contained,
        heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
      ),
    );
  }
}