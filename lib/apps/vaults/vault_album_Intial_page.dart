import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagcash/apps/vaults/business/vault_album_listing_page.dart';
import 'package:tagcash/apps/vaults/user/vault_album_user_listing_page.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/localization/language_constants.dart';

class VaultAlbumInitialScreen extends StatefulWidget {
  VaultAlbumInitialScreenState createState() => VaultAlbumInitialScreenState();
}

class VaultAlbumInitialScreenState extends State<VaultAlbumInitialScreen> {
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppTopBar(
            appBar: AppBar(),
            title: (Provider.of<PerspectiveProvider>(context, listen: false)
                        .getActivePerspective() ==
                    'user')
                ? getTranslated(context, "vaults")
                : getTranslated(context, "my_vaults")),
        body: (Provider.of<PerspectiveProvider>(context, listen: false)
                    .getActivePerspective() ==
                'user')
            ? VaultAlbumuserListingPage()
            : VaultAlbumListingPage());
  }
}
