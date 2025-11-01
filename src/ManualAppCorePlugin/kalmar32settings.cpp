#include "kalmar32settings.h"
#include <QDebug>
#include <QJsonObject>
#include <QSettings>


Kalmar32Settings::Kalmar32Settings(QObject *parent) : SettingsBase(parent) {}

void Kalmar32Settings::loadFromSettings(QSettings &settings,
                                        const QString &prefix) {
  QString pre = prefix.isEmpty() ? "kalmar32/" : prefix;

  setpcTabletDell7230(settings.value(pre + "pcTabletDell7230", "").toString());
  setacDcPowerAdapterDell(
      settings.value(pre + "acDcPowerAdapterDell", "").toString());
  setdcChargerAdapterBattery(
      settings.value(pre + "dcChargerAdapterBattery", "").toString());

  setultrasonicPhasedArrayPulsar(
      settings.value(pre + "ultrasonicPhasedArrayPulsar", "").toString());
  setmanualProbs36(settings.value(pre + "manualProbs36", "").toString());
  setstraightProbs0(settings.value(pre + "straightProbs0", "").toString());

  sethasDcCableBattery(
      settings.value(pre + "hasDcCableBattery", false).toBool());
  sethasEthernetCables(
      settings.value(pre + "hasEthernetCables", false).toBool());
  setdcBatteryBox(settings.value(pre + "dcBatteryBox", "").toString());
  setacDcChargerAdapterBattery(
      settings.value(pre + "acDcChargerAdapterBattery", "").toString());

  setcalibrationBlockSo3r(
      settings.value(pre + "calibrationBlockSo3r", "").toString());
  sethasRepairToolBag(settings.value(pre + "hasRepairToolBag", false).toBool());
  sethasInstalledNameplate(
      settings.value(pre + "hasInstalledNameplate", false).toBool());
}

void Kalmar32Settings::saveToSettings(QSettings &settings,
                                      const QString &prefix) const {
  QString pre = prefix.isEmpty() ? "kalmar32/" : prefix;

  settings.setValue(pre + "pcTabletDell7230", pcTabletDell7230());
  settings.setValue(pre + "acDcPowerAdapterDell", acDcPowerAdapterDell());
  settings.setValue(pre + "dcChargerAdapterBattery", dcChargerAdapterBattery());

  settings.setValue(pre + "ultrasonicPhasedArrayPulsar",
                    ultrasonicPhasedArrayPulsar());
  settings.setValue(pre + "manualProbs36", manualProbs36());
  settings.setValue(pre + "straightProbs0", straightProbs0());

  settings.setValue(pre + "hasDcCableBattery", hasDcCableBattery());
  settings.setValue(pre + "hasEthernetCables", hasEthernetCables());
  settings.setValue(pre + "dcBatteryBox", dcBatteryBox());
  settings.setValue(pre + "acDcChargerAdapterBattery",
                    acDcChargerAdapterBattery());

  settings.setValue(pre + "calibrationBlockSo3r", calibrationBlockSo3r());
  settings.setValue(pre + "hasRepairToolBag", hasRepairToolBag());
  settings.setValue(pre + "hasInstalledNameplate", hasInstalledNameplate());
}

QJsonObject Kalmar32Settings::toJson() const {
  QJsonObject obj;

  obj["pc_tablet_dell_7230"] = pcTabletDell7230();
  obj["ac_dc_power_adapter_dell"] = acDcPowerAdapterDell();
  obj["dc_charger_adapter_battery"] = dcChargerAdapterBattery();

  obj["ultrasonic_phased_array_pulsar"] = ultrasonicPhasedArrayPulsar();
  obj["manual_probs_36"] = manualProbs36();
  obj["straight_probs_0"] = straightProbs0();

  obj["has_dc_cable_battery"] = hasDcCableBattery();
  obj["has_ethernet_cables"] = hasEthernetCables();
  obj["dc_battery_box"] = dcBatteryBox();
  obj["ac_dc_charger_adapter_battery"] = acDcChargerAdapterBattery();

  obj["calibration_block_so_3r"] = calibrationBlockSo3r();
  obj["has_repair_tool_bag"] = hasRepairToolBag();
  obj["has_installed_nameplate"] = hasInstalledNameplate();

  return obj;
}

void Kalmar32Settings::fromJson(const QJsonObject &obj) {
  if (obj.contains("pc_tablet_dell_7230"))
    setpcTabletDell7230(obj["pc_tablet_dell_7230"].toString());
  if (obj.contains("ac_dc_power_adapter_dell"))
    setacDcPowerAdapterDell(obj["ac_dc_power_adapter_dell"].toString());
  if (obj.contains("dc_charger_adapter_battery"))
    setdcChargerAdapterBattery(obj["dc_charger_adapter_battery"].toString());

  if (obj.contains("ultrasonic_phased_array_pulsar"))
    setultrasonicPhasedArrayPulsar(
        obj["ultrasonic_phased_array_pulsar"].toString());
  if (obj.contains("manual_probs_36"))
    setmanualProbs36(obj["manual_probs_36"].toString());
  if (obj.contains("straight_probs_0"))
    setstraightProbs0(obj["straight_probs_0"].toString());

  if (obj.contains("has_dc_cable_battery"))
    sethasDcCableBattery(obj["has_dc_cable_battery"].toBool());
  if (obj.contains("has_ethernet_cables"))
    sethasEthernetCables(obj["has_ethernet_cables"].toBool());
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
