#include "phasar32settings.h"
#include <QDebug>
#include <QJsonObject>
#include <QSettings>


Phasar32Settings::Phasar32Settings(QObject *parent) : SettingsBase(parent) {}

void Phasar32Settings::loadFromSettings(QSettings &settings,
                                       const QString &prefix) {
  QString pre = prefix.isEmpty() ? "phasar32/" : prefix;

  setpcTabletDell7230(settings.value(pre + "pcTabletDell7230", "").toString());
  setpersonalisedNameTag(
      settings.value(pre + "personalisedNameTag", "").toString());
  setacDcPowerAdapterDell(
      settings.value(pre + "acDcPowerAdapterDell", "").toString());
  setdcChargerAdapterBattery(
      settings.value(pre + "dcChargerAdapterBattery", "").toString());

  setultrasonicPhasedArrayPulsar(
      settings.value(pre + "ultrasonicPhasedArrayPulsar", "").toString());
  // Load ultrasonic blocks with dates
  setdcn(settings.value(pre + "dcn", "").toString());
  setdcnDate(settings.value(pre + "dcnDate", "").toString());
  setabBack(settings.value(pre + "abBack", "").toString());
  setabBackDate(settings.value(pre + "abBackDate", "").toString());
  setgfCombo(settings.value(pre + "gfCombo", "").toString());
  setgfComboDate(settings.value(pre + "gfComboDate", "").toString());
  setffCombo(settings.value(pre + "ffCombo", "").toString());
  setffComboDate(settings.value(pre + "ffComboDate", "").toString());
  setabFront(settings.value(pre + "abFront", "").toString());
  setabFrontDate(settings.value(pre + "abFrontDate", "").toString());
  setflange50(settings.value(pre + "flange50", "").toString());
  setflange50Date(settings.value(pre + "flange50Date", "").toString());
  setmanualProbs(settings.value(pre + "manualProbs", "").toString());
  setmanualProbsDate(settings.value(pre + "manualProbsDate", "").toString());
  
  sethasDcCableBattery(settings.value(pre + "hasDcCableBattery", false).toBool());
  sethasEthernetCables(settings.value(pre + "hasEthernetCables", false).toBool());

  setwaterTankWithTap(settings.value(pre + "waterTankWithTap", "").toString());
  setdcBatteryBox(settings.value(pre + "dcBatteryBox", "").toString());
  setacDcChargerAdapterBattery(
      settings.value(pre + "acDcChargerAdapterBattery", "").toString());

  setcalibrationBlockSo3r(
      settings.value(pre + "calibrationBlockSo3r", "").toString());
  sethasRepairToolBag(settings.value(pre + "hasRepairToolBag", false).toBool());
  sethasInstalledNameplate(
      settings.value(pre + "hasInstalledNameplate", false).toBool());
}

void Phasar32Settings::debugPrint() const {
  qDebug() << "=== Phasar32 Settings ===";
  const QMetaObject *meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    QVariant value = prop.read(this);
    qDebug() << prop.name() << "=" << value;
  }
}

void Phasar32Settings::saveToSettings(QSettings &settings,
                                     const QString &prefix) const {
  QString pre = prefix.isEmpty() ? "phasar32/" : prefix;

  settings.setValue(pre + "pcTabletDell7230", pcTabletDell7230());
  settings.setValue(pre + "personalisedNameTag", personalisedNameTag());
  settings.setValue(pre + "acDcPowerAdapterDell", acDcPowerAdapterDell());
  settings.setValue(pre + "dcChargerAdapterBattery", dcChargerAdapterBattery());

  settings.setValue(pre + "ultrasonicPhasedArrayPulsar",
                    ultrasonicPhasedArrayPulsar());
  // Save ultrasonic blocks with dates
  settings.setValue(pre + "dcn", dcn());
  settings.setValue(pre + "dcnDate", dcnDate());
  settings.setValue(pre + "abBack", abBack());
  settings.setValue(pre + "abBackDate", abBackDate());
  settings.setValue(pre + "gfCombo", gfCombo());
  settings.setValue(pre + "gfComboDate", gfComboDate());
  settings.setValue(pre + "ffCombo", ffCombo());
  settings.setValue(pre + "ffComboDate", ffComboDate());
  settings.setValue(pre + "abFront", abFront());
  settings.setValue(pre + "abFrontDate", abFrontDate());
  settings.setValue(pre + "flange50", flange50());
  settings.setValue(pre + "flange50Date", flange50Date());
  settings.setValue(pre + "manualProbs", manualProbs());
  settings.setValue(pre + "manualProbsDate", manualProbsDate());
  
  settings.setValue(pre + "hasDcCableBattery", hasDcCableBattery());
  settings.setValue(pre + "hasEthernetCables", hasEthernetCables());

  settings.setValue(pre + "waterTankWithTap", waterTankWithTap());
  settings.setValue(pre + "dcBatteryBox", dcBatteryBox());
  settings.setValue(pre + "acDcChargerAdapterBattery",
                    acDcChargerAdapterBattery());

  settings.setValue(pre + "calibrationBlockSo3r", calibrationBlockSo3r());
  settings.setValue(pre + "hasRepairToolBag", hasRepairToolBag());
  settings.setValue(pre + "hasInstalledNameplate", hasInstalledNameplate());
}

QJsonObject Phasar32Settings::toJson() const {
  QJsonObject obj;

  obj["pc_tablet_dell_7230"] = pcTabletDell7230();
  obj["personalised_name_tag"] = personalisedNameTag();
  obj["ac_dc_power_adapter_dell"] = acDcPowerAdapterDell();
  obj["dc_charger_adapter_battery"] = dcChargerAdapterBattery();

  obj["ultrasonic_phased_array_pulsar"] = ultrasonicPhasedArrayPulsar();
  // Ultrasonic blocks with dates to JSON
  obj["dcn"] = dcn();
  obj["dcn_date"] = dcnDate();
  obj["ab_back"] = abBack();
  obj["ab_back_date"] = abBackDate();
  obj["gf_combo"] = gfCombo();
  obj["gf_combo_date"] = gfComboDate();
  obj["ff_combo"] = ffCombo();
  obj["ff_combo_date"] = ffComboDate();
  obj["ab_front"] = abFront();
  obj["ab_front_date"] = abFrontDate();
  obj["flange_50"] = flange50();
  obj["flange_50_date"] = flange50Date();
  obj["manual_probs"] = manualProbs();
  obj["manual_probs_date"] = manualProbsDate();
  
  obj["has_dc_cable_battery"] = hasDcCableBattery();
  obj["has_ethernet_cables"] = hasEthernetCables();

  obj["water_tank_with_tap"] = waterTankWithTap();
  obj["dc_battery_box"] = dcBatteryBox();
  obj["ac_dc_charger_adapter_battery"] = acDcChargerAdapterBattery();

  obj["calibration_block_so_3r"] = calibrationBlockSo3r();
  obj["has_repair_tool_bag"] = hasRepairToolBag();
  obj["has_installed_nameplate"] = hasInstalledNameplate();

  return obj;
}

void Phasar32Settings::fromJson(const QJsonObject &obj) {
  if (obj.contains("pc_tablet_dell_7230"))
    setpcTabletDell7230(obj["pc_tablet_dell_7230"].toString());
  if (obj.contains("personalised_name_tag"))
    setpersonalisedNameTag(obj["personalised_name_tag"].toString());
  if (obj.contains("ac_dc_power_adapter_dell"))
    setacDcPowerAdapterDell(obj["ac_dc_power_adapter_dell"].toString());
  if (obj.contains("dc_charger_adapter_battery"))
    setdcChargerAdapterBattery(obj["dc_charger_adapter_battery"].toString());

  if (obj.contains("ultrasonic_phased_array_pulsar"))
    setultrasonicPhasedArrayPulsar(
        obj["ultrasonic_phased_array_pulsar"].toString());
  
  // Load ultrasonic blocks with dates from JSON
  if (obj.contains("dcn")) setdcn(obj["dcn"].toString());
  if (obj.contains("dcn_date")) setdcnDate(obj["dcn_date"].toString());
  if (obj.contains("ab_back")) setabBack(obj["ab_back"].toString());
  if (obj.contains("ab_back_date")) setabBackDate(obj["ab_back_date"].toString());
  if (obj.contains("gf_combo")) setgfCombo(obj["gf_combo"].toString());
  if (obj.contains("gf_combo_date")) setgfComboDate(obj["gf_combo_date"].toString());
  if (obj.contains("ff_combo")) setffCombo(obj["ff_combo"].toString());
  if (obj.contains("ff_combo_date")) setffComboDate(obj["ff_combo_date"].toString());
  if (obj.contains("ab_front")) setabFront(obj["ab_front"].toString());
  if (obj.contains("ab_front_date")) setabFrontDate(obj["ab_front_date"].toString());
  if (obj.contains("flange_50")) setflange50(obj["flange_50"].toString());
  if (obj.contains("flange_50_date")) setflange50Date(obj["flange_50_date"].toString());
  if (obj.contains("manual_probs")) setmanualProbs(obj["manual_probs"].toString());
  if (obj.contains("manual_probs_date")) setmanualProbsDate(obj["manual_probs_date"].toString());
  
  if (obj.contains("has_dc_cable_battery"))
    sethasDcCableBattery(obj["has_dc_cable_battery"].toBool());
  if (obj.contains("has_ethernet_cables"))
    sethasEthernetCables(obj["has_ethernet_cables"].toBool());

  if (obj.contains("water_tank_with_tap"))
    setwaterTankWithTap(obj["water_tank_with_tap"].toString());
  if (obj.contains("dc_battery_box"))
    setdcBatteryBox(obj["dc_battery_box"].toString());
  if (obj.contains("ac_dc_charger_adapter_battery"))
    setacDcChargerAdapterBattery(
        obj["ac_dc_charger_adapter_battery"].toString());

  if (obj.contains("calibration_block_so_3r"))
    setcalibrationBlockSo3r(obj["calibration_block_so_3r"].toString());
  if (obj.contains("has_repair_tool_bag"))
    sethasRepairToolBag(obj["has_repair_tool_bag"].toBool());
  if (obj.contains("has_installed_nameplate"))
    sethasInstalledNameplate(obj["has_installed_nameplate"].toBool());
}