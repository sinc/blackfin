using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Windows.Forms;
using FTD2XX_NET;

namespace bfloader
{
    class MainForm: Form
    {
        private byte[] m_loadedData;
        private bfmanager m_manager;

        private MenuStrip menuStrip;
        private ToolStripMenuItem fileToolStripMenuItem;
        private ToolStripMenuItem openLDRMenuItem;
        private ToolStripMenuItem flashToolStripMenuItem;
        private ToolStripMenuItem eraseMenuItem;
        private ToolStripMenuItem blankCheckingMenuItem;
        private ToolStripMenuItem loadMenuItem;
        private ToolStripMenuItem verifyMenuItem;
        private ToolStripMenuItem chipToolStripMenuItem;
        private ToolStripMenuItem resetMenuItem;
        private StatusStrip statusStrip;
        private ToolStripProgressBar progressBar;
        private ToolStripStatusLabel statusLabel;
        private ToolStripMenuItem readToolStripMenuItem;
        private ToolStripMenuItem connectMenuItem;

        public MainForm(FTDI device)
        {
            InitializeComponent();
            m_manager = new bfmanager(device);
        }

        private void InitializeComponent()
        {
            this.menuStrip = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.openLDRMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.connectMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.flashToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.eraseMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.blankCheckingMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.loadMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.verifyMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.chipToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.resetMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.statusStrip = new System.Windows.Forms.StatusStrip();
            this.progressBar = new System.Windows.Forms.ToolStripProgressBar();
            this.statusLabel = new System.Windows.Forms.ToolStripStatusLabel();
            this.readToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.menuStrip.SuspendLayout();
            this.statusStrip.SuspendLayout();
            this.SuspendLayout();
            // 
            // menuStrip
            // 
            this.menuStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.connectMenuItem,
            this.flashToolStripMenuItem,
            this.chipToolStripMenuItem});
            this.menuStrip.Location = new System.Drawing.Point(0, 0);
            this.menuStrip.Name = "menuStrip";
            this.menuStrip.Size = new System.Drawing.Size(805, 24);
            this.menuStrip.TabIndex = 0;
            this.menuStrip.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.openLDRMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(35, 20);
            this.fileToolStripMenuItem.Text = "File";
            // 
            // openLDRMenuItem
            // 
            this.openLDRMenuItem.Name = "openLDRMenuItem";
            this.openLDRMenuItem.Size = new System.Drawing.Size(156, 22);
            this.openLDRMenuItem.Text = "Open *.ldr file ";
            this.openLDRMenuItem.Click += new System.EventHandler(this.openLDRMenuItem_Click);
            // 
            // connectMenuItem
            // 
            this.connectMenuItem.Name = "connectMenuItem";
            this.connectMenuItem.Size = new System.Drawing.Size(59, 20);
            this.connectMenuItem.Text = "Connect";
            this.connectMenuItem.Click += new System.EventHandler(this.connectMenuItem_Click);
            // 
            // flashToolStripMenuItem
            // 
            this.flashToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.eraseMenuItem,
            this.blankCheckingMenuItem,
            this.loadMenuItem,
            this.verifyMenuItem});
            this.flashToolStripMenuItem.Name = "flashToolStripMenuItem";
            this.flashToolStripMenuItem.Size = new System.Drawing.Size(44, 20);
            this.flashToolStripMenuItem.Text = "Flash";
            // 
            // eraseMenuItem
            // 
            this.eraseMenuItem.Enabled = false;
            this.eraseMenuItem.Name = "eraseMenuItem";
            this.eraseMenuItem.Size = new System.Drawing.Size(154, 22);
            this.eraseMenuItem.Text = "Erase";
            this.eraseMenuItem.Click += new System.EventHandler(this.eraseMenuItem_Click);
            // 
            // blankCheckingMenuItem
            // 
            this.blankCheckingMenuItem.Enabled = false;
            this.blankCheckingMenuItem.Name = "blankCheckingMenuItem";
            this.blankCheckingMenuItem.Size = new System.Drawing.Size(154, 22);
            this.blankCheckingMenuItem.Text = "Blank checking";
            this.blankCheckingMenuItem.Click += new System.EventHandler(this.blankCheckingMenuItem_Click);
            // 
            // loadMenuItem
            // 
            this.loadMenuItem.Enabled = false;
            this.loadMenuItem.Name = "loadMenuItem";
            this.loadMenuItem.Size = new System.Drawing.Size(154, 22);
            this.loadMenuItem.Text = "Load";
            this.loadMenuItem.Click += new System.EventHandler(this.loadMenuItem_Click);
            // 
            // verifyMenuItem
            // 
            this.verifyMenuItem.Enabled = false;
            this.verifyMenuItem.Name = "verifyMenuItem";
            this.verifyMenuItem.Size = new System.Drawing.Size(154, 22);
            this.verifyMenuItem.Text = "Verify";
            this.verifyMenuItem.Click += new System.EventHandler(this.verifyMenuItem_Click);
            // 
            // chipToolStripMenuItem
            // 
            this.chipToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.resetMenuItem,
            this.readToolStripMenuItem});
            this.chipToolStripMenuItem.Name = "chipToolStripMenuItem";
            this.chipToolStripMenuItem.Size = new System.Drawing.Size(40, 20);
            this.chipToolStripMenuItem.Text = "Chip";
            // 
            // resetMenuItem
            // 
            this.resetMenuItem.Enabled = false;
            this.resetMenuItem.Name = "resetMenuItem";
            this.resetMenuItem.Size = new System.Drawing.Size(152, 22);
            this.resetMenuItem.Text = "Reset";
            this.resetMenuItem.Click += new System.EventHandler(this.resetMenuItem_Click);
            // 
            // statusStrip
            // 
            this.statusStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.progressBar,
            this.statusLabel});
            this.statusStrip.Location = new System.Drawing.Point(0, 466);
            this.statusStrip.Name = "statusStrip";
            this.statusStrip.Size = new System.Drawing.Size(805, 22);
            this.statusStrip.TabIndex = 1;
            this.statusStrip.Text = "statusStrip1";
            // 
            // progressBar
            // 
            this.progressBar.Name = "progressBar";
            this.progressBar.Size = new System.Drawing.Size(100, 16);
            // 
            // statusLabel
            // 
            this.statusLabel.Name = "statusLabel";
            this.statusLabel.Size = new System.Drawing.Size(0, 17);
            // 
            // readToolStripMenuItem
            // 
            this.readToolStripMenuItem.Name = "readToolStripMenuItem";
            this.readToolStripMenuItem.Size = new System.Drawing.Size(152, 22);
            this.readToolStripMenuItem.Text = "Read";
            this.readToolStripMenuItem.Click += new System.EventHandler(this.readToolStripMenuItem_Click);
            // 
            // MainForm
            // 
            this.ClientSize = new System.Drawing.Size(805, 488);
            this.Controls.Add(this.statusStrip);
            this.Controls.Add(this.menuStrip);
            this.MainMenuStrip = this.menuStrip;
            this.Name = "MainForm";
            this.menuStrip.ResumeLayout(false);
            this.menuStrip.PerformLayout();
            this.statusStrip.ResumeLayout(false);
            this.statusStrip.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        [STAThread]
        static void Main(string[] args)
        {
            FTDI dev = new FTDI();
            uint num_of_devices = 0;
            bool device_found = false;

            while (!device_found)
            {
                dev.GetNumberOfDevices(ref num_of_devices);
                if (num_of_devices > 0)
                {
                    FTDI.FT_DEVICE_INFO_NODE[] devList = new FTDI.FT_DEVICE_INFO_NODE[num_of_devices];
                    dev.GetDeviceList(devList);
                    foreach (FTDI.FT_DEVICE_INFO_NODE dev_info in devList)
                    {
                        if (dev_info.SerialNumber == bfmanager.kDevice_Descriptor)
                        {
                            device_found = true;
                            break;
                        }
                    }
                    if (device_found)
                    {
                        try
                        {
                            Application.Run(new MainForm(dev));
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show(ex.Message);
                        }
                    }
                }
                else
                {
                    if (MessageBox.Show("Устройство не обнаружено. Подключите и нажмите ОК.", "Ошибка", MessageBoxButtons.OKCancel) ==
                        DialogResult.Cancel)
                    {
                        break;
                    }
                }
            }
        }

        private void openLDRMenuItem_Click(object sender, EventArgs e)
        {
            OpenFileDialog openDialog = new OpenFileDialog();
            openDialog.Filter = "Loader files|*.ldr";
            openDialog.Multiselect = false;
            if (openDialog.ShowDialog() == DialogResult.OK)
            {
                string fileName = openDialog.FileName;
                using (TextReader tr = new StreamReader(fileName))
                {
                    string line;
                    List<byte> dataList = new List<byte>();
                    while ((line = tr.ReadLine()) != null)
                    {
                        if (line.Length > 2)    //0x...
                        {
                            dataList.Add(byte.Parse(line.Substring(2), NumberStyles.HexNumber));
                        }
                    }
                    m_loadedData = dataList.ToArray();
                    //make enable
                    verifyMenuItem.Enabled = true;
                    loadMenuItem.Enabled = true;
                }
            }
        }

        private void eraseMenuItem_Click(object sender, EventArgs e)
        {
            statusLabel.Text = "Erasing memory...";
            if (!m_manager.erase())
            {
                MessageBox.Show("Erasing flash errror");
                statusLabel.Text = "Error";
            }
            else
            {
                statusLabel.Text = "Flash erased";
            }
        }

        private void blankCheckingMenuItem_Click(object sender, EventArgs e)
        {
            statusLabel.Text = "Blank checking memory...";
            if (!m_manager.blankChecking())
            {
                MessageBox.Show("Blank checking error");
                statusLabel.Text = "Error";
            }
            else
            {
                statusLabel.Text = "Memory is blank";
            }
        }

        private void resetMenuItem_Click(object sender, EventArgs e)
        {
            statusLabel.Text = "Running Blackfin...";
            if (!m_manager.reset())
            {
                MessageBox.Show("Reset error");
                statusLabel.Text = "Error";
            }
            else
            {
                loadMenuItem.Enabled = false;
                eraseMenuItem.Enabled = false;
                blankCheckingMenuItem.Enabled = false;
                verifyMenuItem.Enabled = false;
                resetMenuItem.Enabled = false;
                openLDRMenuItem.Enabled = false;
                connectMenuItem.Text = "Connect";
                statusLabel.Text = "Blackfin is working";
            }
        }

        private void connectMenuItem_Click(object sender, EventArgs e)
        {
            if (connectMenuItem.Text == "Connect")
            {
                try
                {
                    m_manager.connect();
                }
                catch (Exception ex)
                {
                    MessageBox.Show(ex.Message);
                    return;
                }
                connectMenuItem.Text = "Disconnect";
                eraseMenuItem.Enabled = true;
                blankCheckingMenuItem.Enabled = true;
                resetMenuItem.Enabled = true;
            }
            else
            {
                m_manager.disconnect();
                eraseMenuItem.Enabled = false;
                blankCheckingMenuItem.Enabled = false;
                verifyMenuItem.Enabled = false;
                resetMenuItem.Enabled = false;
                openLDRMenuItem.Enabled = false;
                connectMenuItem.Text = "Connect";
            }
        }

        private void loadMenuItem_Click(object sender, EventArgs e)
        {
            if (m_loadedData != null)
            {
                statusLabel.Text = "Loading...";
                bool result = m_manager.load(m_loadedData, new progressDelegate(
                    delegate(int percent)
                    {
                        progressBar.Value = percent;
                    }));
                if (result)
                {
                    statusLabel.Text = "Program loaded";
                }
                else
                {
                    MessageBox.Show("Loading error.");
                    statusLabel.Text = "Error";
                }
                progressBar.Value = 0;
            }
        }

        private void verifyMenuItem_Click(object sender, EventArgs e)
        {
            if (m_loadedData != null)
            {
                statusLabel.Text = "Verifying...";
                bool result = m_manager.checkMemory(m_loadedData, new progressDelegate(
                    delegate(int percent)
                    {
                        progressBar.Value = percent;
                    }));
                if (result)
                {
                    statusLabel.Text = "Verify ok";
                }
                else
                {
                    MessageBox.Show("Verify error.");
                    statusLabel.Text = "Error";
                }
                progressBar.Value = 0;
            }
        }

        private void readToolStripMenuItem_Click(object sender, EventArgs e)
        {
            byte[] buf;
            m_manager.bulkRead(2*512+8, out buf);
            SaveFileDialog saveDialog = new SaveFileDialog();
            saveDialog.Filter = "Text files|*.txt";
            if (saveDialog.ShowDialog() == DialogResult.OK)
            {
                string fileName = saveDialog.FileName;
                using (TextWriter tw = new StreamWriter(fileName))
                {
                    int i = 0;
                    for (; i < buf.Length; i++)
                    {
                        if (buf[i + 0] == 0xfa &&
                            buf[i + 1] == 0xce &&
                            buf[i + 2] == 0xca &&
                            buf[i + 3] == 0xfe)
                        {
                            i += 4;
                            break;
                        }
                    }
                    for (; i < buf.Length-1; i+=2)
                    {
                        ushort adc1 = (ushort)((buf[i + 1] << 8) | buf[i]);//big endian?
                        ushort adc2 = (ushort)((buf[i] << 8) | buf[i + 1]);//big endian?
                        tw.WriteLine("{0}\t{1}", (float)(adc1 / 32768.0 - 1.0), (float)(adc2 / 32768.0 - 1.0));
                    }
                }
            }
        }
    }
}
