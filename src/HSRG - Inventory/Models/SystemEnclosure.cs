using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace HSRG___Inventory.Models
{
    [Table("SystemEnclosure")]
    public class SystemEnclosure
    {
        [Key]
        public string ComputerID { get; set; }
        public string Tag { get; set; }
        public string AudibleAlarm { get; set; }
        public string ChassisTypes { get; set; }
        public string HeatGeneration { get; set; }
        public string HotSwappable { get; set; }
        public string InstallDate { get; set; }
        public string LockPresent { get; set; }
        public string PoweredOn { get; set; }
        public string PartNumber { get; set; }
        public string SerialNumber { get; set; }

    }
}