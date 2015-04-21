module TradeLead
  def self.importers
    [TradeLead::FbopenImporter::FullData,
     TradeLead::AustraliaData,
     TradeLead::CanadaData,
     TradeLead::StateData,
     TradeLead::UkData,
     TradeLead::McaData]
  end
end