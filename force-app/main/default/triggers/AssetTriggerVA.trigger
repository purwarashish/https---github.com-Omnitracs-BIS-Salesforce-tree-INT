trigger AssetTriggerVA on Asset (after insert) {

    /*BypassTriggerUtility u = new BypassTriggerUtility();
    if (u.isTriggerBypassed()) {
        return;
    }*/

    VistaAssetVAHandler.handleAssetsVA(Trigger.new);
}