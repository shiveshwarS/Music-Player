
import 'dart:math';

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:hive_flutter/adapters.dart";
import "package:just_audio/just_audio.dart";
import "package:lottie/lottie.dart";
import "package:hertzz/AudioService.dart" as ads;
import "package:hertzz/SongProvider.dart";
import "package:palette_generator/palette_generator.dart";
import "package:provider/provider.dart";
import 'AudioController.dart';
import 'package:audio_service/audio_service.dart';

late final MyAudioHandler _audiohandler;


class home extends StatelessWidget{
  List<ads.AudioModel>? songs;
  home({required this.songs});

  @override
  Widget build(BuildContext context) {
    List<String> l = Hive.box("favourite").get(0,defaultValue: <String>[]);
    var s = Provider.of<SongProvider>(context);
    var t = Provider.of<tabProvider>(context,listen: false);
    // TODO: implement build
    return 
    Padding(
      padding: EdgeInsets.only(top: 3.h,bottom: 70.r),
      child: ListView.builder(
        itemCount: songs!.length+2,
        itemBuilder:(context, index) {
          if(index == 0){
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50.r,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h,horizontal: 23.w),
                    child: Text("Artists",style: TextStyle(color: Colors.white,fontFamily:"robo",fontSize: 22.sp),),
                  ),
                ),
                horlis(names : s.Artist!)
              ],
            );
          }else if(index == 1){
            return (l.isEmpty || (l.length==1 && s.remove))?SizedBox.shrink():Column(
                children: [
                  SizedBox(
                  width: double.infinity,
                  height: 50.r,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h,horizontal: 23.w),
                    child: Text("Favourites",style: TextStyle(color: Colors.white,fontFamily:"robo",fontSize: 22.sp),),
                  ),
                                ),
                  horlis(names: [["Favourites",'']])
                ]
            );
          }
          else{
            return MusicTile(
          name:songs![index-2].name!,
          subname: songs![index-2].author!,
          art: songs![index-2].albumlink!,
          index: index-2,
          playlistname: "none",
          s : s,
          t : t
          );
          }
        },
      )
    );
  }
}

class search extends StatefulWidget{
  List<ads.AudioModel>? songs;
  search({required this.songs});
  @override
  State<search> createState() => _SearchState();
}

class _SearchState extends State<search> {
  TextEditingController? tec;
  int? count;
  List<ads.AudioModel>? result;
  List<int>? indices;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tec = TextEditingController();
    tec!.addListener((){
      if(tec!.text.isNotEmpty){
      fetchsongs(tec!.text.toLowerCase());
      }
    });
    count = 0;
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tec!.dispose();
  }


@override 
  Widget build(BuildContext context) {
    var s = Provider.of<SongProvider>(context);
    var t = Provider.of<tabProvider>(context,listen: false);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: tec,
                  style: TextStyle(fontSize: 12.sp),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search_rounded,size: 25.r,),
                    filled: true,
                    fillColor: const Color.fromARGB(200, 255, 255, 255),
                    hint: Text("Search a Song",style: TextStyle(fontSize: 12.sp),),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r),borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 8.r,bottom: 70.r),
            itemCount: count,
            itemBuilder: (context,index){
              return MusicTile(name: result![index].name!, subname: result![index].author!, art: result![index].albumlink, index: indices![index],playlistname: "none",s : s,t : t);
            }
            ),
        )
      ],
    );
  }
  
  Future<void> fetchsongs(String text) async{
    indices = [];
    result = [];
    for(int i = 0;i < widget.songs!.length;i++){
      if(widget.songs![i].name!.toLowerCase().contains(text)){
        indices!.add(i);
        result!.add(widget.songs![i]);
      }
    }
    setState(() {
      count = result!.length;
    });
  }
}

void main()async{
  await Hive.initFlutter();
  await Hive.openBox("playlistnames");
  await Hive.openBox("playlist");
  await Hive.openBox("favourite");
  WidgetsBinding w = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: w);

  _audiohandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidStopForegroundOnPause: false,
        androidNotificationIcon: 'drawable/notif',
        androidNotificationChannelId: 'com.hertzz.player',
        androidNotificationChannelName: 'Music Playback',
      ),
    );
  runApp(ScreenUtilInit(
    useInheritedMediaQuery: true,
    designSize: const Size(360,690),
    builder: (context, child) {
      ScreenUtil.configure(data: MediaQuery.of(context));
      return HomePage();
    },
  ));
}

class FadeEffect extends StatelessWidget{
  double width,height;
  FadeEffect({super.key, required this.width, required this.height});
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey.shade900,Color.fromARGB(200,33, 33, 33),Color.fromARGB(165, 33, 33, 33),Color.fromARGB(10, 33, 33, 33)],stops: [0.5,.6,.8,1],tileMode: TileMode.clamp,begin: Alignment.bottomCenter,end: Alignment.topCenter)),
      ),
    );
  }
}

class hovercircle extends StatelessWidget{
  Widget child;
  double width;
  hovercircle({super.key, required this.child, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade900,shape: BoxShape.circle,boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(3,3),
              blurRadius: 5,
              spreadRadius: 1
            ),
            BoxShadow(
              color: Colors.grey.shade800,
              offset: Offset(-3,-3),
              blurRadius: 5,
              spreadRadius: .7
            )]),
      width: width,
      child: child,
    );
  }
}

class hoverbox extends StatelessWidget{
  Widget child;
  double width;
  hoverbox({super.key, required this.child, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade900,borderRadius: BorderRadius.circular(10),boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(3,3),
              blurRadius: 5,
              spreadRadius: 1
            ),
            BoxShadow(
              color: Colors.grey.shade800,
              offset: Offset(-3,-3),
              blurRadius: 5,
              spreadRadius: .7
            )]),
      width: width,
      child: child,
    );
  }
}

List plnm = [];

class MusicTile extends StatefulWidget{
  String name;
  String subname;
  String? art;
  int index;
  String playlistname;
  tabProvider t;
  SongProvider s;

  MusicTile({super.key,required this.name, required this.subname, required this.art, required this.index, required this.playlistname, required this.s, required this.t});

  @override
  State<MusicTile> createState() => _MusicTileState();
}

class _MusicTileState extends State<MusicTile> {
  MenuController mc = MenuController();

  List<int> selected = [];

  var box = Hive.box("playlist");

  void addPlaylist(String p, String n, String subname, String art, String albumtitle,SongProvider s, tabProvider t){
    List before = box.get(p,defaultValue: <String>[]);
    if(before.contains(n)){
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Song Already Exists in $p")));
    }
    before.add(n);
    print(before.length);
    box.put(p,before);
    if(s.PlayListName==t.name){
      s.songs!.add(ads.AudioModel(widget.name, subname, albumtitle, art));
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()async {
        if(widget.s.index == widget.index && widget.s.PlayListName==widget.playlistname)return;
        var pname = widget.s.PlayListName;
        if(widget.t.playlist || widget.t.extras){
                  widget.s.state = 0;
                  print(widget.s.state);
                  widget.s.songs = widget.t.songs;
                  widget.s.PlayListName = widget.t.name!;
          }else if(widget.t.tabindex != 2){
            widget.s.state = 0;
            widget.s.reset();
          }
        _audiohandler.pause();
        widget.s.setIndex(widget.index,changed: (pname!=widget.s.PlayListName),t : Provider.of<tabProvider>(context,listen: false));
        widget.s.notify();
        widget.s.max = await _audiohandler.setSource(widget.s.songs![widget.index]);
        _audiohandler.play();
        widget.s.notify();
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 20,left: 10.w,right: 10.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,borderRadius: BorderRadius.circular(10.r),boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(2,2),
                  blurRadius: 5,
                  spreadRadius: 1
                ),
                BoxShadow(
                  color: Colors.grey.shade800,
                  offset: Offset(-1,-1),
                  blurRadius: 5,
                  spreadRadius: .7
                )]),
          child: Padding(
            padding:  EdgeInsets.all(4.r),
            child: Row(
              children: [
                SizedBox(height: 40.r,width: 40.r,child: ClipRRect(borderRadius: BorderRadius.circular(7.r),child: (widget.art!=null)?Image.network(widget.art!,fit: BoxFit.cover,):Icon(Icons.music_note_rounded))),
                SizedBox(width: 7.w,),
                Expanded(child: SizedBox(
                  height: 45.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.name,style: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.bold,color: (widget.s.PlayListName==widget.playlistname&&widget.s.index==widget.index)?Colors.deepOrange:Colors.white,overflow: TextOverflow.ellipsis),),
                          SizedBox(height: 3.r,),
                          Text(widget.subname,style: TextStyle(fontSize: 11.sp,fontWeight: FontWeight.bold,color: Colors.white60,overflow: TextOverflow.ellipsis),),
                        ],
                      ),
                      
                    ],
                  ),
                )),
                Row(
                  children: [
                    SizedBox(width: 40.r,height: 40.r,child: AnimatedSwitcher(duration: Duration(milliseconds: 500),child: (widget.s.PlayListName==widget.playlistname&&widget.s.index==widget.index&&_audiohandler.playing)?LottieBuilder.network("https://lottie.host/1b7f1b7d-f6ac-467a-8650-817c5ffa5557/hvaWf6ycmf.json",fit: BoxFit.cover,):SizedBox.shrink())),
                    MenuAnchor(
                      controller: mc,
                      style: MenuStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.grey.shade800)
                      ),
                      builder: (context, controller, child) {
                        return IconButton(icon: Icon(Icons.more_vert_rounded,color: Colors.white,size: 22.r,),
                        onPressed: (){
                          controller.isOpen ? controller.close() : controller.open();
                        },
                        );
                      },
                      menuChildren: [
                        GestureDetector(
                          onTap: (){
                            showAdaptiveDialog(
                              context: context, 
                              builder: (c){
                                return Dialog(
                                  backgroundColor: Colors.grey.shade900,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Select a PlayList :",style: TextStyle(color: Colors.white,fontSize: 15.sp),),
                                      ),
                                      SizedBox(
                                        height: (plnm.length<5)?plnm.length*31.r+31.r:MediaQuery.of(context).size.height/4,
                                        child: ListView.builder(
                                          itemCount: plnm.length,
                                          itemBuilder: (c,i){
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                            MaterialButton(minWidth: MediaQuery.sizeOf(context).width/1.5,child:Text(plnm[i],style: TextStyle(color: Colors.white,fontSize: 13.sp),),onPressed: () {
                                              addPlaylist(plnm[i],widget.name,widget.subname,widget.art!,"",widget.s,Provider.of<tabProvider>(context,listen: false));
                                              Navigator.of(context).pop();
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Song Added to ${plnm[i]} Successfully"),duration: Duration(seconds: 2),));
                                              mc.close();
                                            }),
                                          ],);
                                        }),
                                      )
                                    ],
                                  )
                                );
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(color: Colors.grey.shade800),
                            child: Padding(
                              padding: EdgeInsets.all(5.r),
                              child: Text((widget.playlistname=="none"||widget.t.extras)?"Add to PlayList":"Add to Another PlayList",style: TextStyle(color: Colors.grey.shade400,fontSize: 11.sp),),
                            ),
                          ),
                        ),
                        (widget.playlistname!="none"&&!widget.t.extras)
                        ?GestureDetector(
                          onTap: (){
                            removeFromPlaylist();
                            mc.close();
                          },
                          child: Container(
                            decoration: BoxDecoration(color: Colors.grey[800]),
                            child: Padding(
                              padding: EdgeInsets.all(5.r),
                              child: Text("Remove From Playlist",style: TextStyle(color: Colors.grey.shade400,fontSize: 11.sp),textAlign: TextAlign.start,),
                              ),
                          ),
                        )
                        :SizedBox.shrink()
                      ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void removeFromPlaylist()async{
    var p = Hive.box("playlist");
    List<String> temp = p.get(widget.playlistname);
    temp.removeAt(widget.index);
    p.put(widget.playlistname, temp);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Song Removed Successfully"),duration: Duration(seconds: 2),));

    if(widget.s.PlayListName==widget.t.name && widget.s.index == widget.index){
        widget.s.songs!.removeAt(widget.index);
        widget.s.setIndex(widget.index);
          if(widget.t.songs!.isEmpty){
          widget.t.extras = widget.t.playlist = false;
          widget.t.notify();
          }
        await _audiohandler.stop();
        await _audiohandler.setSource(widget.s.songs![widget.index]);
        _audiohandler.play();
        widget.s.recalcshuff();
      }else if(widget.s.PlayListName==widget.t.name){
          widget.s.songs!.removeAt(widget.index);
          if(widget.index < widget.s.index!){
            widget.s.index = widget.s.index!-1;
          }
          widget.s.recalcshuff();
        }else{
          widget.t.songs!.removeAt(widget.index);
        }
    widget.s.notify();
    if(widget.t.songs!.isEmpty){
      widget.t.extras = widget.t.playlist = false;
      widget.t.notify();
    }
  }
  
}

class horlis extends StatefulWidget{

  List<List<String>> names = [];

  horlis({required this.names});

  @override
  State<horlis> createState() => _horlisState();
}

class _horlisState extends State<horlis> {
  loadplaylist(String name,int ind,{bool play=false,})async{
    var t = Provider.of<tabProvider>(context,listen: false);
    var s = Provider.of<SongProvider>(context,listen: false);
    List<ads.AudioModel> res;

    if(name == "Favourites"){
      List<String>? names;
      await Hive.openBox(name);
      names = Hive.box("favourite").get(0);
      res = await ads.AudioService.fetchlPlayList(names!);
      res.sort((a,b){
        return names!.indexOf(a.name!).compareTo(names.indexOf(b.name!));
      });
    }else{
     res = await ads.AudioService.fetchArtistSongs(name);
    }
    t.extras = true;
    Provider.of<tabProvider>(context,listen: false).set(name, res,(name!="Favourites")?(widget.names[ind][1].isEmpty)?null:widget.names[ind][1]:null);
    }

  @override
  Widget build(BuildContext context) {
    var s = Provider.of<SongProvider>(context,listen: false);
    var t = Provider.of<tabProvider>(context,listen: false);
    // TODO: implement build
    return Container(
                    height: 180.r,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.all(8.r),
                          itemCount: widget.names.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: (){
                                loadplaylist(widget.names[index][0],index);
                              },
                              child: Padding(
                                padding:  EdgeInsets.only(bottom: 15.r,left: 15.r,right: 15.r),
                                child: hoverbox(width: 110.w,child: Padding(
                                  padding:  EdgeInsets.symmetric(vertical: 8.r,horizontal: 12.r),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 90.r,child: ClipRRect(borderRadius: BorderRadius.circular(10.r),child: (widget.names[index][0]=="Favourites")?Image.asset("assets/fav_img.png",fit: BoxFit.contain,):Image.network(widget.names[index][1],fit: BoxFit.contain,))),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: ((widget.names[index][0]=="Favourites"))?MainAxisAlignment.spaceEvenly:MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(widget.names[index][0],style: TextStyle(fontSize: 10.sp,fontWeight: FontWeight.bold,color: Colors.white),),
                                            ),
                                            (widget.names[index][0]=="Favourites")?Icon(Icons.favorite_rounded,color: Colors.red,size: 22.r,):SizedBox.shrink()
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                              ),
                            );
                                              },),
                        ),
                    ],),
                  );
  }
}

Color? _colorScheme = Colors.grey.shade900;
bool closed = false;


class PlayBar extends StatefulWidget{
  
  @override
  State<PlayBar> createState() => _PlayBarState();
}

class _PlayBarState extends State<PlayBar> {

  bool isopen = false;
  StateSetter? ss;
  PageController? _controller;
  bool isloading = false;
  Duration? buff;
  bool seeking = false;
  bool skipchange = false;
  IconData play = Icons.pause_rounded;
  Box playlists = Hive.box("favourite");
  int? lastind;

  void like(String name,{bool liked = true}){
    var s = Provider.of<SongProvider>(context,listen : false);
    List names = (playlists.get(0,defaultValue: <String>[]));
    if(liked){
      names.add(name);
      playlists.put(0, names);
      if(s.PlayListName=="Favourites"){
        s.remove = false;
      }
    }else{
      if(s.PlayListName=="Favourites"){
        s.setdel(name, playlists, 0);
        s.remove = true;
      }else{
        names.remove(name);
        playlists.put(0, names);
      }
    }
    s.notify();
  }

  String FormatTime(Duration n){
    String td(int n) => n.toString().padLeft(2,'0');
    String formatted = "${td(n.inMinutes)}:${td(n.inSeconds.remainder(60))}";
    return formatted;
  }

  Future<void> loadnext(int? ind) async{
    try{
    SongProvider s = Provider.of<SongProvider>(context,listen: false);    
    if(s.state == 2){
      ind = s.index!;
      _audiohandler.seek(Duration.zero);
      return;
    }
    else if(s.state == 1){
      ind = s.shuffeindex[(s.shufind++)%s.songs!.length];
    }
    else if(ind!=null){
      ind = ind%s.songs!.length;
    }
    else{
      ind = (s.index!+1)%s.songs!.length;
    }
    bool r = s.remove;
    s.setIndex(ind,t: Provider.of<tabProvider>(context,listen: false));
    if(r && s.index! < ind){
      ind--;
    }
    s.notify();
    if(ss!=null&&isopen){ss!((){});}
    if(isloading){
      lastind = ind;
      return;
    } isloading = true;
    _audiohandler.pause();
    s.max = await _audiohandler.setSource(s.songs![s.index!]);
    if(s.index==ind%s.songs!.length)_audiohandler.play();
    s.notify();
    }catch(_){
    }
  }

  void _attachListeners(BuildContext context) {
    _audiohandler.durationStream.listen((d){
      var s = Provider.of<SongProvider>(context,listen:false);
      s.max = d??Duration.zero;
      s.notify();
    });
    _audiohandler.playingStream.listen((onData){
      if(onData == true){
        play = Icons.pause_rounded;
      }else{
        play = Icons.play_arrow_rounded;
      }
      if(ss!=null&&isopen){ss!((){});}
      Provider.of<SongProvider>(context,listen: false).notify();
    });
    _audiohandler.bufferedPositionStream.listen((b){
        buff = b;
    });
  _audiohandler.playerstatestream
    .listen((stat)async {
      var s = Provider.of<SongProvider>(context,listen: false);
    if(stat == ProcessingState.loading){
      isloading = true;
      if (isopen && ss!=null) {
        ss!((){}); 
    }
    }else if(stat == ProcessingState.ready){
      if(lastind == null){
        var palette = (await PaletteGenerator.fromImageProvider(NetworkImage(s.currart!)));
        s.color = palette.darkVibrantColor?.color ?? palette.darkVibrantColor?.color ?? Colors.grey.shade900;
      }
      isloading = false;
      if(lastind != null){
        var last = lastind;
        lastind = null;
        await _audiohandler.setSource(s.songs![last!]);
        _audiohandler.play();
     }
      if (isopen && ss!=null) {
        ss!((){}); 
    }
    }
    if(stat == ProcessingState.completed){
      skipchange = true;
      loadnext(null);
      if(_controller!=null && isopen){
        if(s.state == 0 && !background){
        _controller!.animateToPage(s.index??0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
      }else if(s.state == 1 || background){
        _controller!.jumpToPage(s.index??0);
      }
      }
    }
  });
  _audiohandler.positionStream.listen((d)async {
    if(seeking)return;
    if (mounted) {
        Provider.of<SongProvider>(context,listen: false).curr = d;
      if (isopen && ss!=null) {
        ss!(() {
        },);
      }
    }
  });
}

bool done = false;

  @override
  void dispose() {
    // TODO: implement dispose
    _controller!.dispose();
    super.dispose();
  }

  void startup()async{
    _audiohandler.setnext(() { 
      skipchange = true;
      loadnext(Provider.of<SongProvider>(context,listen: false).index!+1);
      if(_controller!=null && isopen){
      _controller!.animateToPage(Provider.of<SongProvider>(context,listen: false).index??0, duration: Duration(milliseconds: 100), curve: Curves.fastOutSlowIn);
    }});
    
    _audiohandler.setprev((){
      skipchange = true;
      loadnext(Provider.of<SongProvider>(context,listen: false).index!-1);
      if(_controller!=null && isopen){
      _controller!.animateToPage(Provider.of<SongProvider>(context,listen: false).index??0, duration: Duration(milliseconds: 100), curve: Curves.fastOutSlowIn);
    }});

    SongProvider s = Provider.of<SongProvider>(context,listen: false);
    s.setIndex(0);
    _audiohandler.setSource(s.songs![0]);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startup();
    _controller = PageController(initialPage: 0);
    _attachListeners(context);
  }

  void playpause()async{
    if(_audiohandler.playing){
      await _audiohandler.pause();
    }else{
      await _audiohandler.play();
    }

  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    SongProvider s = Provider.of<SongProvider>(context,listen: true);
    return Padding(
      padding: EdgeInsets.only(bottom: 7.r),
      child: GestureDetector(
        onTap: () async{
           isopen = true;
           await showModalBottomSheet(useSafeArea: true,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),isScrollControlled: true,elevation: 0,context: context, builder: (c){
            return StatefulBuilder(
              builder: (c,l) {
                ss = l;
                _controller = PageController(initialPage: s.index!); 
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 15.h),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [s.color!,Colors.grey.shade900],stops: [0,1],begin: Alignment.topCenter,end: Alignment.bottomCenter),color: (_colorScheme!=null)?_colorScheme!:Colors.grey.shade900,borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FittedBox(
                            child: IconButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                              }, icon: Icon(Icons.arrow_back_ios_new_rounded,color: Colors.white,size: 22.r,)
                              ),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 310.h,
                            width: double.infinity,
                            child: SizedBox(
                              width: double.infinity,
                              child: PageView.builder(
                                physics: (s.state==0)?AlwaysScrollableScrollPhysics():NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: Provider.of<SongProvider>(context,listen: false).songs!.length,
                                controller: _controller,
                                onPageChanged: (value) {
                                  if(!skipchange && 1 == (value-s.index!).abs()) {
                                    if(s.remove){
                                      _controller!.jumpToPage(value-1);
                                    }
                                    loadnext(value);
                                  }else{
                                    skipchange = false;
                                  } 
                                },
                                itemBuilder: (context, index) {
                                  return Center(
                                    child: Container(
                                                                  decoration: BoxDecoration(color: _colorScheme!,borderRadius: BorderRadius.circular(10),boxShadow: [BoxShadow(
                                      color: Colors.black.withValues(alpha: .5),
                                      offset: Offset(3,3),
                                      blurRadius: 5,
                                      spreadRadius: 1
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: .5),
                                      offset: Offset(-3,-3),
                                      blurRadius: 5,
                                      spreadRadius: .7
                                    )]),
                                    height: 300.r,
                                    width: 300.r,
                                                                  child:ClipRRect(borderRadius: BorderRadius.circular(10),child: (s.currart!=null)?Image.network(s.songs![index].albumlink!,fit: BoxFit.contain,frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => (wasSynchronouslyLoaded&&frame!=null)
                                                                  ?child
                                                                  :AnimatedOpacity(opacity: frame == null ? 0 : 1,
                                     duration: const Duration(milliseconds: 500),
                                     child: child,
                                   ),):Icon(Icons.music_note_rounded,size: 350,),)),
                                  );
                                },
                                    
                                    
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h,),
                          SizedBox(
                            width: 300.r,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(s.curname??"Select",style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.bold,color: Colors.white),overflow: TextOverflow.ellipsis,),
                                      SizedBox(height: 5,),
                                      Text(s.curartist??"Select",style: TextStyle(fontSize: 12.sp,fontWeight: FontWeight.bold,color: Colors.white60),overflow: TextOverflow.ellipsis,)
                                    ],
                                  ),
                                ),
                                
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: AnimatedSwitcher(
                                          duration: Duration(milliseconds:200),
                                          transitionBuilder: (child, animation) {
                                            return ScaleTransition(scale: animation,child: child,);
                                          },
                                          child: FittedBox(
                                            key: ValueKey(s.isliked),
                                            child: IconButton(
                                              isSelected: s.isliked,
                                              onPressed: (){
                                                ss!((){
                                                  s.isliked=!s.isliked;
                                                  like(s.curname!,liked : s.isliked);
                                                  });
                                              }, 
                                              selectedIcon: Icon(Icons.favorite,color: Colors.deepOrange,size: 22.r,),
                                              icon: Icon(Icons.favorite_outline,color: Colors.deepOrange,size: 22.r,)
                                              ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                    child: AnimatedSwitcher(
                                      duration: Duration(milliseconds:100),
                                      transitionBuilder: (child, animation) {
                                        return ScaleTransition(scale: animation,child: child,);
                                      },
                                      child: FittedBox(
                                        key: ValueKey(s.state),
                                        child: IconButton(
                                          onPressed: (){
                                            s.state = (s.state+1)%3;
                                            if(s.state == 1){
                                              s.recalcshuff();
                                            }
                                            ss!((){});
                                          }, 
                                          icon: Icon((s.state==0)?Icons.shuffle_rounded:(s.state==1)?Icons.shuffle_on_rounded:(s.state==2)?Icons.repeat_on:Icons.error,color: Colors.deepOrange,size: 25,)
                                          ),
                                      ),
                                    ),
                                  ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          ],
                      ),
                      SizedBox(
                        width: 320.r,
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Stack(
                                  children: [
                                    SliderTheme(
                                      data: SliderThemeData(
                                        trackHeight: 2,
                                        thumbShape: SliderComponentShape.noThumb,
                                        thumbColor: Colors.transparent,
                                        activeTrackColor: const Color.fromARGB(176, 255, 86, 34),
                                      ),
                                      child: Slider(
                                        max : s.max.inSeconds.toDouble(),
                                        onChanged: (c){},
                                        value: buff!.inSeconds.clamp(0, s.max.inSeconds).toDouble(),
                                      ),
                                    ),
                                    SliderTheme(
                                      data: SliderThemeData(
                                        trackHeight: 3,
                                        activeTrackColor: Colors.deepOrange,
                                        thumbColor: Colors.deepOrange,
                                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8)
                                      ),
                                      child: Slider(
                                        max : s.max.inSeconds.toDouble(),
                                        onChanged: (c){
                                          ss!((){
                                            seeking = true;
                                            s.curr = Duration(seconds: c.toInt());
                                          });
                                        },
                                        onChangeEnd: (c){
                                          seeking = false;
                                          _audiohandler.seek(s.curr);
                                        },
                                        value: s.curr.inSeconds.clamp(0, s.max.inSeconds).toDouble(),
                                        inactiveColor: const Color.fromARGB(115, 75, 75, 75),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20.w,right: 20.w),
                                  child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  Text(FormatTime(Duration(seconds:s.curr.inSeconds.clamp(0, s.max.inSeconds))),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 10.sp),),
                                  Text(FormatTime(s.max),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 10.sp))
                                  ],
                                 ),
                                ),
                                
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      shadowicon(Icons.fast_rewind_rounded, (){_audiohandler.seek(s.curr-Duration(seconds: min(s.curr.inSeconds, 10)));}),
                                                      shadowicon(Icons.skip_previous_rounded, () {skipchange = true; loadnext(s.index!-1);if(_controller!=null && isopen){
                                  if(s.state==0){_controller!.animateToPage(Provider.of<SongProvider>(context,listen: false).index??0, duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);}
                                  else {_controller!.jumpToPage(Provider.of<SongProvider>(context,listen: false).index??0);}
                                }}),
                                                      SizedBox(height: 60.r,width: 60.r,child:(isloading)?Padding(
                                                        padding: EdgeInsets.all(12.r),
                                                        child: CircularProgressIndicator(color: Colors.white),
                                                      ):AnimatedSwitcher(duration: Duration(milliseconds: 300),key: ValueKey(play),child: shadowicon(play,() => playpause()))),
                                                      shadowicon(Icons.skip_next_rounded,() {skipchange = true; loadnext(s.index!+1); if(_controller!=null && isopen){
                                  if(s.state==0){_controller!.animateToPage(Provider.of<SongProvider>(context,listen: false).index??0, duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);}
                                  else {_controller!.jumpToPage(Provider.of<SongProvider>(context,listen: false).index??0);}
                                }}),
                                shadowicon(Icons.fast_forward_rounded, ()async{
                                  seeking = true;
                                  s.curr = Duration(seconds : min((s.curr+Duration(seconds: 10)).inSeconds,s.max.inSeconds));
                                  _audiohandler.seek(s.curr);
                                  ss!((){});
                                  seeking = false;
                                  }),
                                                    ],
                                                  )
                          ],
                        ),
                      ),
                      SizedBox(height: 5.h,)
                    ],
                  ),
                );
              }
            );
          });
          isopen = false;
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.deepOrange.shade800,borderRadius: BorderRadius.circular(8.r)),
          child : Padding(
              padding:  EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                children: [
                  Container(height: 40.r,width: 40.r,child: ClipRRect(borderRadius: BorderRadius.circular(7.r),child: (s.currart!=null)?Image.network(s.currart!,fit: BoxFit.cover,):Icon(Icons.music_note_rounded,))),
                  SizedBox(width: 10.w,),
                  Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Provider.of<SongProvider>(context).curname??"Select",style: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.bold,color: Colors.white),overflow: TextOverflow.ellipsis,),
                      Text("Playing......",style: TextStyle(fontSize: 11.sp,fontWeight: FontWeight.bold,color: Colors.white60),overflow: TextOverflow.ellipsis,),
                    ],
                  )),
                  IconButton(padding: EdgeInsets.all(0),icon: Icon(play,color: Colors.white,size: 35.r,),onPressed: (){playpause();},)
                ],
              ),
            ),
        ),
      ),
    );
  }
}

class shadowicon extends StatelessWidget{
  IconData? icon;
  GestureTapCallback? onTap;
  shadowicon(this.icon, this.onTap);
   @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: IconButton(onPressed: onTap,icon: Icon(icon,size: 35.r,color: Colors.white,),
      ),
    );
  }
}

class playlist extends StatefulWidget{
  @override
  State<playlist> createState() => _playlistState();
}

class _playlistState extends State<playlist> {
  TextEditingController tc = TextEditingController();

  loadplaylist(String name,{bool play=false})async{
    var t = Provider.of<tabProvider>(context,listen: false);
    var s = Provider.of<SongProvider>(context,listen: false);
    if(play && s.PlayListName == name)return;
    List<String>? names;
    await Hive.openBox(name);
    names = Hive.box("playlist").get(name);
    if(names == null || names.isEmpty)
    {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PlayList is Empty"),duration: Duration(seconds: 3),));
      return;
    }
    List<ads.AudioModel> res = await ads.AudioService.fetchlPlayList(names);
    res.sort((a,b){
      return names!.indexOf(a.name!).compareTo(names.indexOf(b.name!));
    });
    if(play){
      Provider.of<tabProvider>(context,listen: false).set(name, res);
      s.state = 0;
      s.songs = t.songs;
      int index = Random().nextInt(t.songs!.length);
      s.PlayListName = t.name!;
      _audiohandler.pause();
      s.setIndex(index);
      s.notify();
      s.max = await _audiohandler.setSource(s.songs![index]);
      _audiohandler.play();
      s.notify();
    }else{
    Provider.of<tabProvider>(context,listen: false).playlist = true;
    Provider.of<tabProvider>(context,listen: false).set(name, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    var s = Provider.of<SongProvider>(listen: false,context);
    return Padding(
      padding: EdgeInsets.only(bottom: 80.r),
      child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 1), 
      itemCount: plnm.length+1,
      itemBuilder: (itemBuilder,i){
        String? link;
        if(i!=0){List list = Hive.box("playList").get(plnm[i-1],defaultValue: []);
        if(list.isNotEmpty){
          link = Provider.of<SongProvider>(context).temp!.firstWhere((s)=>s.name==list[0]).albumlink;
        }
        }
        return (i==0)?Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              showAdaptiveDialog(context: context, builder: (builder){
                return Dialog(
                  backgroundColor: Colors.grey.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  child: Padding(
                    padding: EdgeInsets.all(8.r),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          flex: 3,
                          child: TextField(
                            controller: tc,
                            style: TextStyle(color: Colors.white,fontSize: 13.sp),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.r),borderSide: BorderSide(color: Colors.black))
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w,),
                        Flexible(child: MaterialButton(color: Colors.grey.shade900,onPressed: (){
                          if(tc.text.isNotEmpty)
                          {
                            if(plnm.contains(tc.text)){
                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Playlist with Name ${tc.text} Already Exists")));
                              return;
                            }
                            Hive.box("playlistnames").add(tc.text);
                            plnm.add(tc.text);
                            Navigator.of(context).pop();
                            setState(() {
                              
                            });
                            tc.clear();
                          }
                        },child: FittedBox(fit : BoxFit.contain,child:Text("Create",style: TextStyle(color: Colors.white,fontSize: 10.sp),),)))
                      ],
                    ),
                  ),
                );
              });
            },
            child: Container(
              constraints: BoxConstraints.expand(),
              color: Colors.transparent,
              child: Center(
                child: Icon(Icons.add,size: 35.r,color: Colors.white,),
              ),
            ),
          ),
        ):Padding(
          padding: EdgeInsets.all(13.r),
          child: Stack(
            children: [
              GestureDetector(
                onTap: ()async{
                   await loadplaylist(plnm[i-1]);
                },
                child: hoverbox(width: double.infinity,child: Stack(
                  children: [
                    Opacity(opacity: .7,child: (link!=null)?ClipRRect(borderRadius: BorderRadius.circular(5.r),child: Image.network(link,fit: BoxFit.cover,)):FittedBox(fit: BoxFit.contain,child: Icon(Icons.music_note_rounded,size: 180,))),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(width: double.infinity,height: 35.h,decoration: BoxDecoration(color: Colors.black.withValues(alpha: .5),borderRadius: BorderRadius.vertical(bottom: Radius.circular(5.r))),child: FittedBox(alignment: Alignment.centerLeft,child: Padding(
                        padding:  EdgeInsets.all(8.r),
                        child: Text(plnm[i-1],style: TextStyle(color: Colors.white,fontSize: 20.sp,fontFamily: 'robo'),),
                      ))),
                    ),
                  ],
                ),),
              ),
              GestureDetector(
                onTap: ()async{
                  await loadplaylist(plnm[i-1],play: true);
                },
                child: Align(
                        alignment: Alignment.bottomRight,
                        child: Transform.translate(offset: Offset(15.w,20.h),child: FittedBox(child: SizedBox(height: 60.r,width: 60.r,child: Stack(children: [Align(alignment: Alignment.center,child: Container(height: 30.r,width: 30.r,decoration: BoxDecoration(color: Colors.white),)),Align(alignment: Alignment.center,
                        child: Icon((s.PlayListName==plnm[i-1])?Icons.pause_circle_rounded:Icons.play_circle_rounded,size: 55.r,color: Colors.deepOrange,))])))),
                      ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: MenuAnchor(
                  style: MenuStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.grey.shade800)
                  ),
                  controller: MenuController(),
                  builder: (context, controller, child) {
                      return Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(5.r)),color: Colors.black.withValues(alpha: .4)),
                        child: IconButton(icon: Icon(Icons.more_horiz,color: Colors.white,size: 20.r,),
                        onPressed: (){
                          controller.isOpen ? controller.close() : controller.open();
                        },
                        ),
                      );
                    },
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () {
                        deleteplayList(i-1);
                      },
                      child: Text("Delete",style: TextStyle(color: Colors.white,fontSize: 13.sp),),
                    )
                  ]
                  ),
              )
            ],
          ),
        );
      }),
    );
  }

  deleteplayList(int i){
    try{
    Hive.box("playlistnames").deleteAt(i);
    Hive.box("playlist").delete(plnm[i]);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${plnm[i]} Removed Successfully")));
    plnm.removeAt(i);
    setState(() {
      
    });
    }catch(e,a){
      print("$e $a");
    }
  }
}


class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  tabProvider t;
  SongProvider s;
  _StickyHeaderDelegate({required this.t, required this.s});
  @override
  double get minExtent => 50.r; // Minimum height of the header
  @override
  double get maxExtent => 60.r; // Maximum height of the header (same as minExtent to make it static)

  loadlist()async{
    s.state = 0;
    s.songs = t.songs;
    int index = Random().nextInt(t.songs!.length);
    s.PlayListName = t.name!;
    _audiohandler.pause();
    s.setIndex(index);
    s.notify();
    s.max = await _audiohandler.setSource(s.songs![index]);
    _audiohandler.play();
    s.notify();
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double off = shrinkOffset/maxExtent;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.r)),color: Color.lerp(Colors.grey[900], const Color.fromARGB(255, 189, 62, 23), off)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(t.name!,style: TextStyle(color: Colors.white,fontSize: 22.sp,fontFamily: 'robo'),),
                      (t.extras&&t.name=="Favourites")?Wrap(children: [SizedBox(width: 6.w,),FittedBox(child: Icon(Icons.favorite_rounded,color: Colors.deepOrange,size: 25.r,),)]):SizedBox.shrink()
                    ],
                  ),
                ]
              ),
            ),
            Expanded(
              child: Consumer<SongProvider>(
                builder: (context, value, child) => 
                Transform.translate(
                  offset: Offset(0, 20*off),
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(shape: BoxShape.circle,color: Colors.grey.shade900,border: Border.all(width: 3,color: const Color.fromARGB(255, 189, 62, 23))),
                    child: Center(
                      child: IconButton(
                      padding: EdgeInsets.all(0),
                        onPressed: (){
                        if(t.name!=s.PlayListName){
                          loadlist();
                        }
                        else if(_audiohandler.playing){
                          _audiohandler.pause();
                        }else {
                          _audiohandler.play();
                        }
                      },icon: Icon((_audiohandler.playing&&t.name==s.PlayListName)?Icons.pause_rounded:Icons.play_arrow_rounded,size: 30.r,color: Colors.deepOrange,)),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class playlistPage extends StatefulWidget{
  double _opacity = 1;
  @override
  State<playlistPage> createState() => _playlistPageState();
}

class _playlistPageState extends State<playlistPage> {
  int tileindex  = -1;


  @override
  Widget build(BuildContext context) {
    var s = Provider.of<SongProvider>(context,listen: false);
    var t = Provider.of<tabProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (d,r) async{
        var t = Provider.of<tabProvider>(context,listen: false);
        if(t.extras){t.extras=false;}
        else {t.playlist = false;}
        t.notify();
      },
      child: (t.songs==null)?CircularProgressIndicator():CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.grey[900],
            expandedHeight: 200.h,
            centerTitle: true,
            flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  double opacity = ((constraints.maxHeight / 200.h)).clamp(0.0, 1.0);
                  widget._opacity = opacity;
      
                  return Opacity(
                      opacity: opacity,
                      child: Center(
                        child: FittedBox(
                            fit: BoxFit.contain,
                            child: 
                              Padding(
                                padding:  EdgeInsets.symmetric(vertical: 10.r),
                                child: SizedBox(
                                  height: 250.r,
                                  child: hoverbox(width: 250.r,
                                    child: Padding(
                                      padding: EdgeInsets.all(4.r),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10.r),
                                        child: Image.network(
                                          (t.link!=null)?t.link!:t.songs![0].albumlink!,fit: BoxFit.contain,
                                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                            if(wasSynchronouslyLoaded && frame == null){
                                              return child;
                                            }else{
                                              return AnimatedOpacity(opacity: (frame!=null) ? 1 :0, duration: Duration(milliseconds: 500),child: child,);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ),
                  );
                }
                  ) 
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(t: t,s: s)
            ),
          SliverPadding(
            padding: EdgeInsets.only(top: 28.r,bottom: 70.r),
            sliver:  Consumer<SongProvider>(
              builder: (context, value, child) => 
               (t.extras && t.name!="Favourites")?SliverList.builder(
                itemCount: t.songs!.length,
                itemBuilder: (context, index) {
                  return MusicTile(
                      name:  t.songs![index].name!,
                      subname: t.songs![index].author!,
                      art: t.songs![index].albumlink,
                      index: index,
                      playlistname: t.name!,
                      s: s,
                      t: t,
                      );
                }
                ):SliverReorderableList(
                proxyDecorator: (child, index, animation) {
                  return Transform.scale(
                    scale: .7,
                    child: Container(
                      child: child,
                    ),
                  );
                },
                itemCount: t.songs!.length,
                onReorder: (oldIndex, newIndex) {
                  swap(t, s, newIndex, oldIndex);
                },
                itemBuilder: (context, index) {
                  return ReorderableDelayedDragStartListener(
                    index: index,
                    key: Key("$index"),
                    child: MusicTile(
                        name:  t.songs![index].name!,
                        subname: t.songs![index].author!,
                        art: t.songs![index].albumlink,
                        index: index,
                        playlistname: t.name!,
                        s: s,
                        t: t,
                        ),
                  );
                },
                ),
            ),
          ),
        ],
      ),
    );
  }

  void swap(tabProvider t,SongProvider s, int n, int o){
    if(n>o)n--;
    var item = t.songs!.removeAt(o);
    t.songs!.insert(n, item);
    if(t.name==s.PlayListName){
      s.songs = t.songs;
      if(s.index==o){
        s.index = n;
      }else if(s.index! <= n && s.index! > o){
        s.index = s.index!-1;
      }else if(s.index! < o && s.index! >= n){
        s.index = s.index!+1;
      }
    }
    saveorder(t);
  }

  void saveorder(tabProvider t){
    List<String> temp = List.generate(t.songs!.length, (i)=>t.songs![i].name!);
    if(t.name!="Favourites"){Hive.box("playlist").put(t.name, temp);}
    else{Hive.box("favourite").put(0, temp);}
  }
}

bool background = false;

class HomePage extends StatefulWidget{
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  int curind = 1;

load()async{
  songs = await ads.AudioService.retrieveAudios();
  Artist = await ads.AudioService.fetchArtistNames();
  songs!.shuffle();
  Hive.box("playlistnames").toMap().forEach((key, value){plnm.add(value);});
  pages.add(search(songs: songs));
  pages.add(home(songs: songs));
  pages.add(playlist());
  pages.add(playlistPage());
  setState(() {
  });
  FlutterNativeSplash.remove();
}

List<ads.AudioModel>? songs;
List<List<String>>? Artist;
List<Widget> pages=[];
PageController fragctr = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();
    load();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disp();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> disp()async{
    await _audiohandler.stop();
    _audiohandler.dispose();
  } 
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Container(
          decoration: BoxDecoration(color: Colors.grey.shade900),
          child: SafeArea(
            child: ChangeNotifierProvider(
              create: (context)=> tabProvider(),
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    backgroundColor: Colors.grey.shade900,
                    body: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.r),
                              child: Text(
                                "Music Player",
                                 style: TextStyle(
                                  fontSize: 20.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                                 ),
                                ),
                            )
                          ],
                        ),
                        (songs==null)?CircularProgressIndicator():ChangeNotifierProvider(
                          create: (context) => SongProvider(songs,Artist),
                          child: Expanded(
                            child: Stack(
                              children: [
                                Consumer<tabProvider>(
                                  builder: (context, value, child) {
                                    if(value.tabindex!=2 && value.playlist){
                                      value.playlist = false;
                                    }else if(value.tabindex!=1 && value.extras){
                                      value.extras = false;
                                    }
                                    return AnimatedSwitcher(
                                    duration: Duration(milliseconds: 1000),
                                    switchInCurve: Curves.fastOutSlowIn,
                                    switchOutCurve: Curves.fastOutSlowIn,
                                    child: pages[(value.playlist||value.extras)?3:value.tabindex],
                                    );
                                  }
                                ),
                                Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FadeEffect(width: double.infinity, height: 120.h)
                                      ),
                                
                                     Align(
                                      alignment: Alignment.bottomRight,
                                       child: SizedBox(
                                        height: 60.r,
                                         child: Row(
                                           children: [
                                             Expanded(
                                               child: Padding(
                                                 padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                 child: PlayBar(),
                                               ),
                                             ),
                                           ],
                                         ),
                                       ),
                                     ),
                              ],
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                    bottomNavigationBar: Theme(
                      data: ThemeData(canvasColor: Colors.grey.shade900,splashColor: Colors.transparent),
                      child: Consumer<tabProvider>(
                        builder: (context, value, child) => 
                         BottomNavigationBar(
                          currentIndex: value.tabindex,
                          selectedItemColor: Colors.white,
                          unselectedItemColor: Colors.white54,
                          elevation: 0,
                          showUnselectedLabels: false,
                          selectedFontSize: 10.sp,
                          type: BottomNavigationBarType.shifting,
                          onTap: (value){
                              Provider.of<tabProvider>(context,listen: false).tabindex = value;
                              Provider.of<tabProvider>(context,listen: false).notify();                      
                          },
                          items: [
                            BottomNavigationBarItem(icon: Icon(Icons.search_rounded,),label: "Search"),
                            BottomNavigationBarItem(icon: Icon(Icons.home,),label: "Home"),
                            BottomNavigationBarItem(icon: Icon(Icons.playlist_play,),label: "PlayLists")
                          ]
                          ),
                      ),
                    ),
                  );
                }
              ),
            )
            ),
        ),
      ),
    );
  }

  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    // Check app lifecycle state changes
    if(state == AppLifecycleState.paused){
      background = true;
    }
    if(state == AppLifecycleState.resumed){
      background = false;
    }
    if (state == AppLifecycleState.detached) {
      // The app is in the background or closed, set the flag
       _audiohandler.stop();
    }
  }
}