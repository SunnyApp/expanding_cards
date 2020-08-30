import 'package:expanding_cards/expanding_cards.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:logging_config/logging_config.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class AlbumInfo {
  final String name;
  final String year;
  final String cover;
  final List<String> details;
  final Color color;
  final double headerHeight;

  const AlbumInfo(
    this.name,
    this.year,
    this.cover,
    this.details, {
    this.color,
    this.headerHeight,
  });
}

class _MyAppState extends State<MyApp> {
  List<AlbumInfo> _data;
  @override
  void initState() {
    super.initState();
    configureLogging(LogConfig.root(Level.FINE, handler: LoggingHandler.dev()));
    _data = [
      AlbumInfo(
        "Piper at the Gates of Dawn",
        "1967",
        "https://www.rollingstone.com/wp-content/uploads/2018/06/rs-125610-092313-weekend-rock-06-500-1379961503.jpg",
        [
          "Many psychedelic rock albums from 1967 sound very dated today, but The Piper at the Gates of Dawn sounds remarkably fresh 46 years after it arrived on record store shelves. The group had been gigging for two years at this point and had a minor hit on the charts with \"Arnold Layne.\" EMI Records saw huge potential in the group and their charismatic frontman Syd Barrett, and they let them record in Abbey Road with Beatles engineer Norman Smith. They even watched the Beatles record \"Lovely Rita\" midway through the sessions. The result of the sessions was nothing nearly as commercial as Sgt. Pepper, but a work that appealed to hip teenagers all over England. The group was poised for bigger and better things, but not long after it came out Barrett began suffering severe mental problems. The group briefly worried they wouldn't be able to carry on without him.",
        ],
        color: Colors.redAccent,
        headerHeight: 150,
      ),
      AlbumInfo(
        "Wish You Were Here",
        "1975",
        "https://www.rollingstone.com/wp-content/uploads/2018/06/rs-125613-092313-weekend-rock-03-500-1379961731.jpg",
        [
          '''
          Pink Floyd were one of the biggest bands on the planet when they began writing songs for Wish You Were Here, and it made them reflect on their early days a decade earlier. Many newer Floyd fans had never even heard of Syd Barrett, but the band wouldn't exist without him and they wanted to honor him with a musical tribute. "Shine On You Crazy Diamond" is a beautiful salute to the lost genius, and it features some of David Gilmour's greatest guitar work. "Wish You Were Here" has become Pink Floyd's most enduring composition, while "Welcome to the Machine" and "Have a Cigar" are biting critiques of the record industry. The album has aged remarkably well and is a perfect entry point for new fans. 
          '''
              .trim(),
          '''
          Pink Floyd were one of the biggest bands on the planet when they began writing songs for Wish You Were Here, and it made them reflect on their early days a decade earlier. Many newer Floyd fans had never even heard of Syd Barrett, but the band wouldn't exist without him and they wanted to honor him with a musical tribute. "Shine On You Crazy Diamond" is a beautiful salute to the lost genius, and it features some of David Gilmour's greatest guitar work. "Wish You Were Here" has become Pink Floyd's most enduring composition, while "Welcome to the Machine" and "Have a Cigar" are biting critiques of the record industry. The album has aged remarkably well and is a perfect entry point for new fans. 
          '''
              .trim(),
          '''
          Pink Floyd were one of the biggest bands on the planet when they began writing songs for Wish You Were Here, and it made them reflect on their early days a decade earlier. Many newer Floyd fans had never even heard of Syd Barrett, but the band wouldn't exist without him and they wanted to honor him with a musical tribute. "Shine On You Crazy Diamond" is a beautiful salute to the lost genius, and it features some of David Gilmour's greatest guitar work. "Wish You Were Here" has become Pink Floyd's most enduring composition, while "Welcome to the Machine" and "Have a Cigar" are biting critiques of the record industry. The album has aged remarkably well and is a perfect entry point for new fans. 
          '''
              .trim(),
        ],
        headerHeight: 200,
      ),
      AlbumInfo(
        "Dark Side of the Moon",
        "1967",
        "https://www.rollingstone.com/wp-content/uploads/2018/06/rs-125615-092313-weekend-rock-01-500-1379961884.jpg",
        [
          '''
          Pink Floyd were one of the biggest bands on the planet when they began writing songs for Wish You Were Here, and it made them reflect on their early days a decade earlier. Many newer Floyd fans had never even heard of Syd Barrett, but the band wouldn't exist without him and they wanted to honor him with a musical tribute. "Shine On You Crazy Diamond" is a beautiful salute to the lost genius, and it features some of David Gilmour's greatest guitar work. "Wish You Were Here" has become Pink Floyd's most enduring composition, while "Welcome to the Machine" and "Have a Cigar" are biting critiques of the record industry. The album has aged remarkably well and is a perfect entry point for new fans. 
          '''
              .trim(),
        ],
        color: Colors.black,
      ),
      AlbumInfo(
        "The Wall",
        "1979",
        "https://www.rollingstone.com/wp-content/uploads/2018/06/rs-125611-092313-weekend-rock-05-500-1379961566.jpg",
        [
          '''
          Roger Waters didn't love being a rock star. Hit singles, screaming fans and stadium concerts weren't his goal, and compromising with his bandmates was becoming an increasingly difficult task. The fans at Floyd shows also drove him crazy, yelling out for hits and barely paying attention to complex songs like "Dogs." Waters lost his temper during a show in Montreal and actually spit on some fans near the front. He felt a need to construct a real wall between himself and the audience. That was the spark that inspired The Wall, an ambitious double LP about a Waters-like rock star dealing the aftermath of his father's death in World War Two. Unlike Animals, he was willing to write some short singles like "Young Lust," "Mother," "Hey You" and "Another Brick in the Wall Part Two." The latter song had a disco beat and became a massive smash. 
          '''
              .trim(),
        ],
        color: Colors.black12,
        headerHeight: 170,
      ),
      AlbumInfo(
        "The Division Bell",
        "1994",
        "https://www.rollingstone.com/wp-content/uploads/2018/06/rs-125606-092313-weekend-rock-10-500-1379961073.jpg",
        [
          '''
          The Pink Floyd that released The Division Bell in 1994 would have been unrecognizable to fans who last saw the group at the UFO Club in 1966. Only drummer Nick Mason and keyboardist Richard Wright remained from that crew. Frontman Syd Barrett was a distant memory, and even Roger Waters had been out for nearly a decade. This was now David Gilmour's band, and his wife, Polly Samson, wrote the lyrics. Even though they were competing against new bands like Weezer and Green Day, the album was a modest hit. (Beavis and Butt-head, however, were highly critical of the video for "High Hopes.") Most fans were far more psyched for the tour that followed The Division Bell. Nobody knew it would be the band's last waltz. 
          '''
              .trim(),
        ],
        color: Color.fromRGBO(104, 146, 246, 1),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          toolbarOpacity: 0.7,
          title: const Text('Pink Floyd Albums'),
        ),
        body: Builder(builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(children: [
              for (final album in _data)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 8,
                  ),
                  child: _TestExpandingCard(
                    title: album.name,
                    subtitle: album.year,
                    imageUrl: album.cover,
                    footerColor: album.color,
                    headerHeight: album.headerHeight,
                    expandedDetailTiles: [
                      for (final detail in album.details)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(detail),
                        ),
                    ],
                  ),
                )
//              GestureDetector(
//                  behavior: HitTestBehavior.opaque,
//                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
//                        builder: (context) => card,
//                      )),
//                  child:

//              ),
            ]),
          );
        }),
      ),
    );
  }
}

class _TestExpandingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Widget> expandedDetailTiles;
  final Color footerColor;
  final double headerHeight;

  const _TestExpandingCard(
      {Key key,
      this.title,
      this.imageUrl,
      this.expandedDetailTiles,
      this.headerHeight,
      this.subtitle,
      this.footerColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpandingCard(
      backgroundColor: Colors.white,
      theme: PlatformCardTheme.ofRadius(
        radiusAmount: 12,
      ),
      header: HeroBar(
        height: 135,
        expandedHeight: 200,
//        child: CachedNetworkImage(
//          imageUrl: imageUrl,
//          fit: BoxFit.cover,
//          alignment: Alignment.topCenter,
//        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      alwaysShown: (context) => [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: HeroText(
            (_) => Text(title, style: _),
            startStyle: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.normal),
            endStyle: TextStyle(
                color: Colors.black, fontSize: 32, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: HeroText(
            (_) => Text(subtitle, style: _),
            startStyle:
                TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 20),
            endStyle:
                TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 24),
          ),
        )
      ],
      headerHeight: headerHeight,
      showClose: true,
      footer: footerColor != null
          ? HeroBar(
              height: 60,
              expandedHeight: 100,
              child: Container(
                color: footerColor,
                child: Center(),
              ))
          : null,
      collapsedSection: Container(
          padding: const EdgeInsets.all(10), child: Text("Tap to see details")),
      discriminator: "${title}-${subtitle}",
      expandedSection: Column(mainAxisSize: MainAxisSize.min, children: [
        if (expandedDetailTiles?.isNotEmpty != true)
          Center(child: Text("Nothing to display!")),
        if (expandedDetailTiles != null)
          for (final tile in expandedDetailTiles)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: tile,
            ),
      ]),
    );
  }
}
