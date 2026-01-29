#include "phasar32settings.h"

#include <QDebug>
#include <QJsonObject>
#include <QSettings>


Phasar32Settings::Phasar32Settings(QObject* parent)
    : SettingsBase(parent)
{
}

void Phasar32Settings::loadFromSettings(QSettings& settings, const QString& prefix)
{
  QString pre = prefix.isEmpty() ? "phasar32/" : prefix;

  setpcTabletDell7230(settings.value(pre + "pcTabletDell7230", "").toString());
  setacDcPowerAdapterDell(settings.value(pre + "acDcPowerAdapterDell", "").toString());
  setdcChargerAdapterBattery(settings.value(pre + "dcChargerAdapterBattery", "").toString());

  setultrasonicPhasedArrayPulsar(settings.value(pre + "ultrasonicPhasedArrayPulsar", "").toString());
  // Load ultrasonic blocks with dates
  setdcn(settings.value(pre + "dcn", "").toString());
  setabBack(settings.value(pre + "abBack", "").toString());
  setgfCombo(settings.value(pre + "gfCombo", "").toString());
  setffCombo(settings.value(pre + "ffCombo", "").toString());
  setabFront(settings.value(pre + "abFront", "").toString());
  setflange50(settings.value(pre + "flange50", "").toString());
  setmanualProbs(settings.value(pre + "manualProbs", "").toString());

  sethasDcCableBattery(settings.value(pre + "hasDcCableBattery", false).toBool());
  sethasEthernetCables(settings.value(pre + "hasEthernetCables", false).toBool());

  setwaterTankWithTap(settings.value(pre + "waterTankWithTap", "").toString());
  setdcBatteryBox(settings.value(pre + "dcBatteryBox", "").toString());
  sethasAcDcChargerAdapterBattery(settings.value(pre + "hasAcDcChargerAdapterBattery", false).toBool());

  setcalibrationBlockSo3r(settings.value(pre + "calibrationBlockSo3r", "").toString());
  sethasRepairToolBag(settings.value(pre + "hasRepairToolBag", false).toBool());
  sethasInstalledNameplate(settings.value(pre + "hasInstalledNameplate", false).toBool());
}

void Phasar32Settings::debugPrint() const
{
  qDebug() << "=== Phasar32 Settings ===";
  const QMetaObject* meta = this->metaObject();
  for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
    QMetaProperty prop = meta->property(i);
    QVariant value = prop.read(this);
    qDebug() << prop.name() << "=" << value;
  }
}

void Phasar32Settings::saveToSettings(QSettings& settings, const QString& prefix) const
{
  QString pre = prefix.isEmpty() ? "phasar32/" : prefix;

  settings.setValue(pre + "pcTabletDell7230", pcTabletDell7230());
  settings.setValue(pre + "acDcPowerAdapterDell", acDcPowerAdapterDell());
  settings.setValue(pre + "dcChargerAdapterBattery", dcChargerAdapterBattery());

  settings.setValue(pre + "ultrasonicPhasedArrayPulsar", ultrasonicPhasedArrayPulsar());
  // Save ultrasonic blocks with dates
  settings.setValue(pre + "dcn", dcn());
  settings.setValue(pre + "abBack", abBack());
  settings.setValue(pre + "gfCombo", gfCombo());
  settings.setValue(pre + "ffCombo", ffCombo());
  settings.setValue(pre + "abFront", abFront());
  settings.setValue(pre + "flange50", flange50());
  settings.setValue(pre + "manualProbs", manualProbs());

  settings.setValue(pre + "hasDcCableBattery", hasDcCableBattery());
  settings.setValue(pre + "hasEthernetCables", hasEthernetCables());

  settings.setValue(pre + "waterTankWithTap", waterTankWithTap());
  settings.setValue(pre + "dcBatteryBox", dcBatteryBox());
  settings.setValue(pre + "hasAcDcChargerAdapterBattery", hasAcDcChargerAdapterBattery());

  settings.setValue(pre + "calibrationBlockSo3r", calibrationBlockSo3r());
  settings.setValue(pre + "hasRepairToolBag", hasRepairToolBag());
  settings.setValue(pre + "hasInstalledNameplate", hasInstalledNameplate());
}

QJsonObject Phasar32Settings::toJson() const
{
  QJsonObject obj;

  obj["pc_tablet_dell_7230"] = pcTabletDell7230();
  obj["ac_dc_power_adapter_dell"] = acDcPowerAdapterDell();
  obj["dc_charger_adapter_battery"] = dcChargerAdapterBattery();

  obj["ultrasonic_phased_array_pulsar"] = ultrasonicPhasedArrayPulsar();
  // Ultrasonic blocks with dates to JSON
  obj["dcn"] = dcn();
  obj["ab_back"] = abBack();
  obj["gf_combo"] = gfCombo();
  obj["ff_combo"] = ffCombo();
  obj["ab_front"] = abFront();
  obj["flange_50"] = flange50();
  obj["manual_probs"] = manualProbs();

  obj["has_dc_cable_battery"] = hasDcCableBattery();
  obj["has_ethernet_cables"] = hasEthernetCables();

  obj["water_tank_with_tap"] = waterTankWithTap();
  obj["dc_battery_box"] = dcBatteryBox();
  obj["has_ac_dc_charger_adapter_battery"] = hasAcDcChargerAdapterBattery();

  obj["calibration_block_so_3r"] = calibrationBlockSo3r();
  obj["has_repair_tool_bag"] = hasRepairToolBag();
  obj["has_installed_nameplate"] = hasInstalledNameplate();

  return obj;
}

void Phasar32Settings::fromJson(const QJsonObject& obj)
{
  if (obj.contains("pc_tablet_dell_7230")) setpcTabletDell7230(obj["pc_tablet_dell_7230"].toString());
  if (obj.contains("ac_dc_power_adapter_dell"))
    setacDcPowerAdapterDell(obj["ac_dc_power_adapter_dell"].toString());
  if (obj.contains("dc_charger_adapter_battery"))
    setdcChargerAdapterBattery(obj["dc_charger_adapter_battery"].toString());

  if (obj.contains("ultrasonic_phased_array_pulsar"))
    setultrasonicPhasedArrayPulsar(obj["ultrasonic_phased_array_pulsar"].toString());

  // Load ultrasonic blocks with dates from JSON
  if (obj.contains("dcn")) setdcn(obj["dcn"].toString());
  if (obj.contains("ab_back")) setabBack(obj["ab_back"].toString());
  if (obj.contains("gf_combo")) setgfCombo(obj["gf_combo"].toString());
  if (obj.contains("ff_combo")) setffCombo(obj["ff_combo"].toString());
  if (obj.contains("ab_front")) setabFront(obj["ab_front"].toString());
  if (obj.contains("flange_50")) setflange50(obj["flange_50"].toString());
  if (obj.contains("manual_probs")) setmanualProbs(obj["manual_probs"].toString());

  if (obj.contains("has_dc_cable_battery")) sethasDcCableBattery(obj["has_dc_cable_battery"].toBool());
  if (obj.contains("has_ethernet_cables")) sethasEthernetCables(obj["has_ethernet_cables"].toBool());

  if (obj.contains("water_tank_with_tap")) setwaterTankWithTap(obj["water_tank_with_tap"].toString());
  if (obj.contains("dc_battery_box")) setdcBatteryBox(obj["dc_battery_box"].toString());
  if (obj.contains("has_ac_dc_charger_adapter_battery"))
    sethasAcDcChargerAdapterBattery(obj["has_ac_dc_charger_adapter_battery"].toBool());

  if (obj.contains("calibration_block_so_3r"))
    setcalibrationBlockSo3r(obj["calibration_block_so_3r"].toString());
  if (obj.contains("has_repair_tool_bag")) sethasRepairToolBag(obj["has_repair_tool_bag"].toBool());
  if (obj.contains("has_installed_nameplate"))
    sethasInstalledNameplate(obj["has_installed_nameplate"].toBool());
}