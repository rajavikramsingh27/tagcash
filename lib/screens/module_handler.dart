import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagcash/apps/agents/agent_locations_map_screen.dart';
import 'package:tagcash/apps/auction/user/auction_screen.dart';
import 'package:tagcash/apps/biller_setup/biller_setup_list_screen.dart';
import 'package:tagcash/apps/booking/main_booking_screen.dart';
import 'package:tagcash/apps/buy_load/buy_load_screen.dart';
import 'package:tagcash/apps/charity/charity_manage_screen.dart';
import 'package:tagcash/apps/coupons/coupons_created_list_screen.dart';
import 'package:tagcash/apps/coupons/coupons_manage_screen.dart';
import 'package:tagcash/apps/create_currency/currencies_list_screen.dart';
import 'package:tagcash/apps/dating/dating_home_screen.dart';
import 'package:tagcash/apps/debit_cards/debit_cards_screen.dart';
import 'package:tagcash/apps/expense/expense_screen.dart';
import 'package:tagcash/apps/hackathon/hackathon_list_screen.dart';
import 'package:tagcash/apps/helptutorial/help_tutorials_screen.dart';
import 'package:tagcash/apps/helptutorial/tutorial_user_detail_screen.dart';
import 'package:tagcash/apps/helptutorial/tutorial_user_home_screen.dart';
import 'package:tagcash/apps/helptutorial/tutorial_user_list_screen.dart';
import 'package:tagcash/apps/invoicing/invoicing_screen.dart';
import 'package:tagcash/apps/lending/lending_main_screen.dart';
import 'package:tagcash/apps/master_cards/master_cards_screen.dart';
import 'package:tagcash/apps/newsfeed/user/newsfeed_list_screen.dart';
import 'package:tagcash/apps/pay_bills/pay_bills_manage_screen.dart';
import 'package:tagcash/apps/red_envelopes/red_envelopes_screen.dart';
import 'package:tagcash/apps/requests/requests_manage_screen.dart';
import 'package:tagcash/apps/rewards/rewards_screen.dart';
import 'package:tagcash/apps/scratchcards/scratchcards_list_screen.dart';
import 'package:tagcash/apps/shopping/user/shop_detail_screen.dart';
import 'package:tagcash/apps/vaults/vault_album_Intial_page.dart';
import 'package:tagcash/apps/vouchers/vouchers_manage_screen.dart';
import 'package:tagcash/apps/vtc/vtc_courses_screen.dart';
import 'package:tagcash/models/module.dart';
import 'package:tagcash/providers/perspective_provider.dart';
import 'package:tagcash/screens/dynamic_module_screen.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/apps/shopping/shopping_list_screen.dart';

class ModuleHandler {
  static load(BuildContext context, Module moduleData) {
    AppConstants.activeModule = moduleData.id.toString();

    if (moduleData.moduleType == 'tagcash') {
      tagcashModule(context, moduleData.moduleCode);
    } else if (moduleData.moduleType == 'template') {
      templateModule(context, moduleData.templateDetails);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DynamicModuleScreen(
            title: moduleData.name,
            url: AppConstants.getServer() == 'live'
                ? moduleData.urlLive
                : moduleData.urlBeta,
            type: moduleData.moduleType,
            moduleId: moduleData.id.toString(),
          ),
        ),
      );
    }
  }

  static tagcashModule(BuildContext context, String moduleCode) {
    var toModule;

    switch (moduleCode) {
      case "buy_load":
        toModule = BuyLoadScreen();
        break;
      case "pay_bills":
        toModule = PayBillsManageScreen();
        break;
      case "biller_setup":
        toModule = BillerSetupListScreen();
        break;
      case "vtc":
        toModule = VtcCoursesScreen();
        break;
      case "lending":
        toModule = LendingMainScreen();
        break;
      case "agent":
        toModule = AgentLocationsMapScreen();
        break;
      case "charity":
        toModule = CharityManageScreen();
        break;
      case "coupons":
        if (Provider.of<PerspectiveProvider>(context, listen: false)
                .getActivePerspective() ==
            'user') {
          toModule = CouponsManageScreen();
        } else {
          toModule = CouponsCreatedListScreen();
        }
        break;
      case "expense":
        toModule = ExpenseScreen();
        break;
      case "invoicing":
        toModule = InvoicingScreen();
        break;
      case "rewards":
        toModule = RewardsScreen();
        break;
      case "shopping":
        toModule =
            ShoppingListScreen(moduleCode: "new_shopping"); //moduleCode);
        break;
      case "create_currency":
        toModule = CurrenciesListScreen();
        break;
      case "vouchers":
        toModule = VouchersManageScreen();
        break;
      case "booking":
        toModule = MainBookingScreen();
        break;
      case "red_envelopes":
        toModule = RedEnvelopesScreen();
        break;
      case "debit_cards":
        toModule = DebitCardsScreen();
        break;
      case "scratch_card":
        toModule = ScratchcardsListScreen();
        break;
      case "requests":
        toModule = RequestsManageScreen();
        break;
      case "dating":
        toModule = DatingHomeScreen();
        break;
      case "help_tutorials":
        toModule = TutorialUserHomeScreen();
        break;
      case "create_tutorials":
        toModule = HelpTutorialsScreen();
        break;
      case "auction":
        toModule = AuctionScreen();
        break;
      case "master_card":
        toModule = MasterCardsScreen();
        break;
      case "hackathon":
        toModule = HackathonListScreen();
        break;
      case "vault":
        toModule = VaultAlbumInitialScreen();
        break;
      case "news_feed":
        toModule = NewsFeedListScreen();
        break;
    }
    if (toModule != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => toModule,
        ),
      );
    }
  }

  static templateModule(BuildContext context, TemplateDetails templateDetails) {
    var toModule;

    switch (templateDetails.templateCode) {
      case "help_tutorials":
        if (templateDetails.templateData.length == 1) {
          toModule = TutorialUserDetailScreen(
              tutorial_id: templateDetails.templateData[0]);
        } else {
          toModule = TutorialUserListScreen(
              inputTutorialIds: templateDetails.templateData);
        }
        break;
      case "shopping":
        toModule = ShopDetailScreen(shopId: templateDetails.templateData[0]);
        break;
      case "dating":
        toModule = DatingHomeScreen();
        break;
    }

    if (toModule != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => toModule,
        ),
      );
    }
  }
}
