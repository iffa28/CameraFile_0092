import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praktikumkamera/bloc/camera_bloc.dart';
import 'package:praktikumkamera/bloc/camera_event.dart';
import 'package:praktikumkamera/bloc/camera_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CameraBloc>();

    return Scaffold(
      appBar: AppBar(title: Text('Beranda')),
      body: SafeArea(
        child: BlocConsumer<CameraBloc, CameraState>(
          listener: (context, state) {
            if (state is CameraReady && state.snackbarMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.snackbarMessage!)));
              context.read<CameraBloc>().add(ClearSnackbar());
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera),
                        label: Text('Ambil Foto'),
                        onPressed: () {
                          // Inisialisasi kamera jika belum siap
                            if (state is! CameraReady) {
                              bloc.add(RequestPermission());
                              bloc.add(InitializeCamera());
                            }
                            bloc.add(OpenCameraAndCapture(context));
                        },
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.folder),
                      label: Text('Pilih dari Galeri'),
                      onPressed:
                          () => context.read<CameraBloc>().add(
                            PickImageFromGallery(),
                          ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20),

                  BlocBuilder<CameraBloc, CameraState>(
                    builder: (context, state) {
                      final imageFile =
                          state is CameraReady ? state.imageFile : null;

                          return imageFile !=null
                          ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(
                                  imageFile,
                                  width: double.infinity,
                                ),
                              ),
                              Text('Gambar disimpan di: ${imageFile.path}'),
                              ElevatedButton.icon(
                                icon: Icon(Icons.delete),
                              label: Text('Hapus Gambar'),
                              onPressed: () => context
                              .read<CameraBloc>()
                              .add(DeleteImage())
                              ),
                            ],
                          )
                          : const Padding(padding: EdgeInsets.all(12),
                          child: Text('Belum ada gambar diambil/dipilih.'),
                          );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
