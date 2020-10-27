public with sharing class ContractAmender {
    public QuoteModel load(String contractId, String context) {
        String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, context);
        return (QuoteModel)JSON.deserialize(quoteJSON, QuoteModel.class);
    }
}