import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/vaults/models/album_content.dart';
import 'package:tagcash/apps/vaults/models/album_details.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/services/networking.dart';
import 'package:video_player/video_player.dart';
import 'package:tagcash/localization/language_constants.dart';

class VaultAlbumPreviewPage extends StatefulWidget {
  final AlbumContent fileObj;
  final albumId;

  VaultAlbumPreviewPage({Key key, this.fileObj, this.albumId});

  VaultAlbumPreviewPageState createState() => VaultAlbumPreviewPageState();
}

class VaultAlbumPreviewPageState extends State<VaultAlbumPreviewPage> {
  bool isLoading = false;

  VideoPlayerController _controller;
  var uploadType;
  var pdfUrl;
  List kk = [];
  bool showDetailsBo = false;
  var albumContentId;
  bool videoFavStatus = false;
  var fileurl;
  @override
  void initState() {
    if (widget.albumId == null) {
      fileurl = widget.fileObj.fileUrl;
      uploadType = widget.fileObj.uploadType;
      if (uploadType == "video") {
        _controller = VideoPlayerController.network(
          widget.fileObj.fileUrl,
        );

        _controller.addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            if (_controller.value.position.toString() !=
                "0:00:00.000000") /*This checking is required here,otherwise video will not play*/
              _onFinishPlaying();
          } else {
            setState(() {});
          }
        });
        _controller.setLooping(false);
        _controller.initialize().then((_) => setState(() {}));
        _controller.play();
      }
    } else {
      getSliderData();
      showDetailsBo = false;
      videoFavStatus = false;
    }

    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }

    super.dispose();
  }

  getSliderData() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};

    apiBodyObj['album_data_id'] = widget.fileObj.id;
    apiBodyObj['album_id'] = widget.albumId;

    Map<String, dynamic> response =
        await NetworkHelper.request('Vaults/GetSlider', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      uploadType = response['result']['upload_type'];

      if (uploadType == "video") {
        videoFavStatus = response['result']['fav_status'];
        _controller =
            VideoPlayerController.network(response['result']['file_url']);

        _controller.addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            if (_controller.value.position.toString() !=
                "0:00:00.000000") /*This checking is required here,otherwise video will not play*/
              _onFinishPlaying();
          } else {
            setState(() {});
          }
        });
        _controller.setLooping(false);
        _controller.initialize().then((_) => setState(() {}));
        _controller.play();
      } else if (uploadType == "image") {
        kk.clear();
        kk.addAll(response['result']['image_slider']);
      } else {
        pdfUrl = response['result']['file_url'];
      }
    }
  }

  void _onFinishPlaying() {
    Navigator.of(context).pop();
  }

  showInfoDetials() {
    if (showDetailsBo == true) {
      setState(() {
        showDetailsBo = false;
      });
    } else {
      setState(() {
        showDetailsBo = true;
      });
    }
  }

  addTofavourate(obj) async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};

    apiBodyObj['album_data_id'] = obj['id'];

    Map<String, dynamic> response = await NetworkHelper.request(
        'vaults/addAlbumDataToFavouriteNonFavourite', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      int index = kk.indexOf(obj);
      if (obj['fav_status'] == true) {
        setState(() {
          kk[index]['fav_status'] = false;
        });
      } else {
        setState(() {
          kk[index]['fav_status'] = true;
        });
      }
    }
  }

  addVideoTofavourate() async {
    setState(() {
      isLoading = true;
    });
    Map<String, String> apiBodyObj = {};

    apiBodyObj['album_data_id'] = widget.fileObj.id;

    Map<String, dynamic> response = await NetworkHelper.request(
        'vaults/addAlbumDataToFavouriteNonFavourite', apiBodyObj);

    setState(() {
      isLoading = false;
    });

    if (response["status"] == "success") {
      if (videoFavStatus == true) {
        setState(() {
          videoFavStatus = false;
        });
      } else {
        setState(() {
          videoFavStatus = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var getScreenHeight = MediaQuery.of(context).size.height - 80;

    return Scaffold(
        appBar: AppTopBar(
          appBar: AppBar(),
          title: getTranslated(context, "vault_preview"),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            uploadType == "video"
                ? SafeArea(
                    child: Stack(
                      children: [
                        _controller == null
                            ? Center(child: CircularProgressIndicator())
                            : Container(
                                color: Colors.black,
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: _controller.value.aspectRatio,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: <Widget>[
                                        Container(
                                          color: Colors.black,
                                          child: VideoPlayer(_controller),
                                        ),
                                        _PlayPauseOverlay(
                                            controller: _controller),
                                        VideoProgressIndicator(_controller,
                                            allowScrubbing: true),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        widget.albumId != null
                            ? Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: videoFavStatus
                                      ? Icon(
                                          Icons.favorite,
                                          color: Colors.redAccent,
                                        )
                                      : Icon(
                                          Icons.favorite_border,
                                          color: Colors.redAccent,
                                        ),
                                  onPressed: () {
                                    addVideoTofavourate();
                                  },
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  )
                : uploadType == "image"
                    ? widget.albumId != null
                        ? Stack(
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                    height: getScreenHeight,
                                    enableInfiniteScroll: false,
                                    viewportFraction: 1.0),
                                items: <Widget>[
                                  for (var i = 0; i < kk.length; i++)
                                    Stack(
                                      children: [
                                        ListView(
                                          children: [
                                            Container(
                                                height: showDetailsBo
                                                    ? getScreenHeight - 120
                                                    : getScreenHeight,
                                                child: Hero(
                                                  tag: 'imageHero',
                                                  child: Image.network(
                                                    kk[i]['file_url'],
                                                    fit: BoxFit.fitHeight,
                                                  ),
                                                )),
                                            showDetailsBo
                                                ? Container(
                                                    color: Colors.white70,
                                                    height: 120,
                                                    child: ListTile(
                                                      title: Text(
                                                          kk[i]['photo_name']),
                                                      subtitle: Text(
                                                          kk[i]['photo_notes']),
                                                    ),
                                                  )
                                                : SizedBox()
                                          ],
                                        ),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: IconButton(
                                            icon: showDetailsBo
                                                ? Icon(
                                                    Icons.fullscreen_exit_sharp,
                                                    color: Colors.redAccent,
                                                  )
                                                : Icon(
                                                    Icons.info,
                                                    color: Colors.redAccent,
                                                  ),
                                            onPressed: () {
                                              showInfoDetials();
                                            },
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: IconButton(
                                            icon: kk[i]['fav_status']
                                                ? Icon(
                                                    Icons.favorite,
                                                    color: Colors.redAccent,
                                                  )
                                                : Icon(
                                                    Icons.favorite_border,
                                                    color: Colors.redAccent,
                                                  ),
                                            onPressed: () {
                                              addTofavourate(kk[i]);
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                ],
                              ),
                            ],
                          )
                        : new Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: Hero(
                              tag: 'imageHero',
                              child: Image.network(
                                widget.fileObj.fileUrl,
                                fit: BoxFit.fill,
                              ),
                            ))
                    // : uploadType == "pdf"
                    //     ? SfPdfViewer.network(
                    //         pdfUrl,
                    //         key: _pdfViewerKey,
                    //       )
                    : SizedBox(),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ));
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
