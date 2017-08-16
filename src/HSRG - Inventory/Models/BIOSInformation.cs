using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace HSRG___Inventory.Models
{
    [Table("BIOSInformation")]
    public class BIOSInformation
    {
      
            [Key]
            public string ComputerID { get; set; }
            public string Manufacturer { get; set; }
            public string Name { get; set; }
            public string BIOSVersion { get; set; }
            public string PrimaryBIOS { get; set; }
            public string ReleaseDate { get; set; }
            public string SMBIOSBIOSVersion { get; set; }
            public int SMBIOSMajorVersion { get; set; }
            public int SMBIOSMinorVersion { get; set; }
    }
}