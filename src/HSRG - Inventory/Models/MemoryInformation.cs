using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace HSRG___Inventory.Models
{
    [Table("MemoryInformation")]
    public class MemoryInformation
    {
        [Key]
        public string ComputerID { get; set; }
        [Key]
        public string BankLabel { get; set; }
        public string DeviceLocator { get; set; }
        public string Capacity { get; set; }
        public string Manufacturer { get; set; }
        public string PartNumber { get; set; }
        public string SerialNumber { get; set; }
        public string Speed { get; set; }

    }
}