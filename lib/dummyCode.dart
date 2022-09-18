// FutureBuilder<List<int>>(
//           future: _listOfId,

//           // For the IDS #################
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               return ListView(
//                 children: snapshot.data!.asMap().values.toList().map((e) {
//                   // For the News ...............
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     return FutureBuilder<News?>(
//                       future: _getTheNews(e),
//                       builder:
//                           (BuildContext context, AsyncSnapshot newsSnapshot) {
//                         if (newsSnapshot.connectionState ==
//                             ConnectionState.done) {
//                           return Text(newsSnapshot.data.title);
//                         } else {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                       },
//                     );
//                   } else {
//                     return const Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   }
//                 }).toList(),
//               );
//             } else {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//           },
//         )