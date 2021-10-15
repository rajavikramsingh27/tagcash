import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tagcash/apps/wallet/models/family_member.dart';
import 'package:tagcash/components/loading.dart';
import 'package:tagcash/localization/language_constants.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/utils/validator.dart';

class AddFamilyAccount extends StatefulWidget {
  final String walletId;
  final FamilyMember familyMember;

  const AddFamilyAccount({
    Key key,
    this.walletId,
    this.familyMember,
  }) : super(key: key);

  @override
  _AddFamilyAccountState createState() => _AddFamilyAccountState();
}

class _AddFamilyAccountState extends State<AddFamilyAccount> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool enableAutoValidate = false;

  TextEditingController _idController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _limitController = TextEditingController();

  bool updatingMember = false;
  bool ownAccountPossible = false;
  FamilyMember editingFamilyMember;

  @override
  void initState() {
    super.initState();

    if (widget.familyMember != null) {
      editingFamilyMember = widget.familyMember;
      updatingMember = true;

      enableAutoValidate = false;
      _nameController.text = widget.familyMember.nickName;
      _limitController.text = widget.familyMember.maxAmount.toString();
      if (widget.familyMember.transferToOwnAcc == 1) {
        ownAccountPossible = true;
      } else {
        ownAccountPossible = false;
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void addMemberHandler() async {
    setState(() {
      isLoading = true;
    });

    FocusScope.of(context).unfocus();

    Map<String, String> apiBodyObj = {};
    apiBodyObj['nick_name'] = _nameController.text;
    apiBodyObj['max_amount'] = _limitController.text;
    if (ownAccountPossible) {
      apiBodyObj['transfer_to_own_acc'] = '1';
    } else {
      apiBodyObj['transfer_to_own_acc'] = '0';
    }

    String apiUrl;
    if (updatingMember) {
      apiBodyObj['member_id'] = editingFamilyMember.id.toString();
      apiUrl = 'FamilyAccount/UpdateMember';
    } else {
      apiBodyObj['user_id'] = _idController.text;
      apiBodyObj['wallet_id'] = widget.walletId;
      apiUrl = 'FamilyAccount/AddMembers';
    }

    Map<String, dynamic> response =
        await NetworkHelper.request(apiUrl, apiBodyObj);

    isLoading = false;
    if (response['status'] == 'success') {
      // Map responseMap = response['result'];

      if (updatingMember) {
        showError('Successfully updated');
      } else {
        showError('Successfully added');
      }
      Navigator.pop(context, true);
    } else {
      if (response['error'] == 'already_member_of_a_family_account') {
        showError('Already member of a family account');
      } else if (response['error'] == 'kyc_verification_failed') {
        showError('KYC verification required');
      } else if (response['error'] == 'user_or_merchant_invalid' ||
          response['error'] == 'user_not_found') {
        showError('Invalid user detail');
      } else if (response['error'] == 'permission_denied') {
        showError(
            'You do not have sufficient permissions to perform this action.');
      } else {
        showError(getTranslated(context, 'error_occurred'));
      }
    }
    setState(() {});
  }

  showError(String message) {
    Fluttertoast.showToast(msg: message, fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: enableAutoValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                getTranslated(context, 'family_member'),
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              updatingMember
                  ? Text(
                      '${getTranslated(context, 'user')} : ${editingFamilyMember.userId}',
                      style: Theme.of(context).textTheme.subtitle1,
                    )
                  : TextFormField(
                      controller: _idController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.email),
                        labelText:
                            getTranslated(context, 'phone_no_id_or_email'),
                      ),
                      validator: (value) {
                        if (!Validator.isRequired(value,
                            allowEmptySpaces: false)) {
                          return getTranslated(context, 'phone_no_id_or_email');
                        }
                        return null;
                      },
                    ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  icon: Icon(Icons.person),
                  labelText: getTranslated(context, 'nickname'),
                ),
                validator: (value) {
                  if (!Validator.isRequired(value, allowEmptySpaces: true)) {
                    return getTranslated(context, 'nickname_required');
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _limitController,
                decoration: InputDecoration(
                  icon: Icon(Icons.account_balance_wallet),
                  labelText: getTranslated(context, 'monthly_spend_limit'),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (!Validator.isRequired(value, allowEmptySpaces: false)) {
                    return getTranslated(context, 'set_monthly_spend_limit');
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: Text(
                      getTranslated(context, 'can_transfer_to_own_account')),
                  value: ownAccountPossible,
                  onChanged: (newValue) {
                    setState(() {
                      ownAccountPossible = newValue;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text(updatingMember
                    ? getTranslated(context, 'update')
                    : getTranslated(context, 'add_family_member')),
                onPressed: () {
                  setState(() {
                    enableAutoValidate = true;
                  });
                  if (_formKey.currentState.validate()) {
                    addMemberHandler();
                  }
                },
              )
            ],
          ),
          isLoading ? Container(child: Center(child: Loading())) : SizedBox(),
        ],
      ),
    );
  }
}
