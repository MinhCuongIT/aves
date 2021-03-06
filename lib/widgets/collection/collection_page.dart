import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/collection/thumbnail_collection.dart';
import 'package:aves/widgets/common/behaviour/double_back_pop.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/drawer/app_drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionPage extends StatelessWidget {
  static const routeName = '/collection';

  final CollectionLens collection;

  const CollectionPage(this.collection);

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: ChangeNotifierProvider<CollectionLens>.value(
        value: collection,
        child: Scaffold(
          body: WillPopScope(
            onWillPop: () {
              if (collection.isSelecting) {
                collection.clearSelection();
                collection.browse();
                return SynchronousFuture(false);
              }
              return SynchronousFuture(true);
            },
            child: DoubleBackPopScope(
              child: ThumbnailCollection(),
            ),
          ),
          drawer: AppDrawer(
            source: collection.source,
          ),
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
  }
}
