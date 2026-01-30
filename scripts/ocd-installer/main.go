/*
go.mod content:
module github.com/openchamber/ocd-installer

go 1.21

require (
	github.com/charmbracelet/bubbles v0.16.1
	github.com/charmbracelet/bubbletea v0.24.2
	github.com/charmbracelet/lipgloss v0.8.0
)
*/

package main

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/progress"
	"github.com/charmbracelet/bubbles/spinner"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Steps
const (
	stepMenu = iota
	stepInstallPM
	stepInstallChecking
	stepInstallAliases
	stepInstallShortcuts
	stepInstallConfirm
	stepInstalling
	stepInstallDone
	stepUninstallConfirmText
	stepUninstallOptions
	stepUninstalling
	stepUninstallDone
	stepSysInfo
)

type tickMsg time.Time

var (
	titleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("#00FFFF")).
			MarginBottom(1)
	
	selectedStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("#00FFFF"))
	successStyle  = lipgloss.NewStyle().Foreground(lipgloss.Color("#00FF00"))
	faintStyle    = lipgloss.NewStyle().Foreground(lipgloss.Color("#888888"))
	headerStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("#FFFFFF")).Background(lipgloss.Color("#333333")).Padding(0, 1)
	docStyle      = lipgloss.NewStyle().Margin(1, 2)
)

type model struct {
	step         int
	cursor       int
	menuChoices  []string
	pmChoices    []string
	aliasChoices []string
	scChoices    []string
	uninstOpts   []string
	
	selectedPM      int
	selectedAliases map[int]struct{}
	selectedShortcuts map[int]struct{}
	selectedUninst  map[int]struct{}
	
	textInput textinput.Model
	spinner   spinner.Model
	progress  progress.Model
	
	width  int
	height int
}

func initialModel() model {
	ti := textinput.New()
	ti.Placeholder = "type 'yes'"
	ti.CharLimit = 10
	ti.Width = 20

	s := spinner.New()
	s.Spinner = spinner.Dot
	s.Style = lipgloss.NewStyle().Foreground(lipgloss.Color("#00FFFF"))

	p := progress.New(progress.WithDefaultGradient())

	return model{
		step:        stepMenu,
		menuChoices: []string{"📦 Install/Update OCD", "🗑️  Uninstall", "ℹ️  System Info", "🚪 Exit"},
		pmChoices:   []string{"Bun (Recommended)", "pnpm", "npm", "Auto-detect"},
		aliasChoices: []string{"ocd", "openchamber-desktop", "custom"},
		scChoices:   []string{"Desktop", "Start Menu", "Dock"},
		uninstOpts:  []string{"Remove OCD", "Remove Core", "Remove Shortcuts"},
		
		selectedAliases:   map[int]struct{}{0: {}, 1: {}},
		selectedShortcuts: map[int]struct{}{0: {}, 1: {}},
		selectedUninst:    map[int]struct{}{0: {}, 2: {}},
		
		textInput: ti,
		spinner:   s,
		progress:  p,
	}
}

func (m model) Init() tea.Cmd {
	return tea.Batch(spinner.Tick, textinput.Blink)
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c":
			return m, tea.Quit
		case "q":
			if m.step == stepMenu {
				return m, tea.Quit
			}
		}

	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
		m.progress.Width = msg.Width - 10

	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd

	case tickMsg:
		if m.progress.Percent() >= 1.0 {
			if m.step == stepInstalling {
				m.step = stepInstallDone
			} else {
				m.step = stepUninstallDone
			}
			return m, nil
		}
		increment := 0.05
		if m.step == stepUninstalling {
			increment = 0.1
		}
		return m, tea.Batch(
			m.progress.SetPercent(m.progress.Percent()+increment),
			tickCmd(),
		)

	case progress.FrameMsg:
		newModel, cmd := m.progress.Update(msg)
		if pm, ok := newModel.(progress.Model); ok {
			m.progress = pm
		}
		return m, cmd
	}

	// Step-specific updates
	return m.updateByStep(msg)
}

func (m model) updateByStep(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch m.step {
	case stepMenu:
		return m.updateMenu(msg)
	case stepInstallPM:
		return m.updateInstallPM(msg)
	case stepInstallChecking:
		if _, ok := msg.(checkDoneMsg); ok {
			m.step = stepInstallAliases
			m.cursor = 0
			return m, nil
		}
		// Simulated check
		return m, tea.Tick(time.Second*2, func(t time.Time) tea.Msg { return checkDoneMsg{} })
	case stepInstallAliases:
		return m.updateCheckbox(msg, m.aliasChoices, m.selectedAliases, stepInstallShortcuts, stepInstallPM)
	case stepInstallShortcuts:
		return m.updateCheckbox(msg, m.scChoices, m.selectedShortcuts, stepInstallConfirm, stepInstallAliases)
	case stepInstallConfirm:
		if key, ok := msg.(tea.KeyMsg); ok && key.String() == "enter" {
			m.step = stepInstalling
			return m, tea.Batch(m.progress.SetPercent(0), tickCmd())
		}
		if key, ok := msg.(tea.KeyMsg); ok && key.String() == "esc" {
			m.step = stepInstallShortcuts
		}
	case stepUninstallConfirmText:
		var cmd tea.Cmd
		if key, ok := msg.(tea.KeyMsg); ok {
			if key.String() == "enter" && strings.ToLower(m.textInput.Value()) == "yes" {
				m.step = stepUninstallOptions
				m.cursor = 0
				return m, nil
			}
			if key.String() == "esc" {
				m.step = stepMenu
				m.cursor = 1
			}
		}
		m.textInput, cmd = m.textInput.Update(msg)
		return m, cmd
	case stepUninstallOptions:
		return m.updateCheckbox(msg, m.uninstOpts, m.selectedUninst, stepUninstalling, stepUninstallConfirmText)
	case stepUninstalling:
		// Logic handled by tickMsg
	case stepSysInfo:
		if key, ok := msg.(tea.KeyMsg); ok && (key.String() == "enter" || key.String() == "esc") {
			m.step = stepMenu
			m.cursor = 2
		}
	case stepInstallDone, stepUninstallDone:
		if key, ok := msg.(tea.KeyMsg); ok && key.String() == "enter" {
			m.step = stepMenu
			m.cursor = 0
		}
	}
	return m, nil
}

type checkDoneMsg struct{}

func tickCmd() tea.Cmd {
	return tea.Tick(time.Millisecond*200, func(t time.Time) tea.Msg {
		return tickMsg(t)
	})
}

func (m *model) updateMenu(msg tea.Msg) (tea.Model, tea.Cmd) {
	if key, ok := msg.(tea.KeyMsg); ok {
		switch key.String() {
		case "up", "k":
			if m.cursor > 0 {
				m.cursor--
			}
		case "down", "j":
			if m.cursor < len(m.menuChoices)-1 {
				m.cursor++
			}
		case "enter":
			switch m.cursor {
			case 0:
				m.step = stepInstallPM
				m.cursor = 0
			case 1:
				m.step = stepUninstallConfirmText
				m.textInput.Focus()
			case 2:
				m.step = stepSysInfo
			case 3:
				return m, tea.Quit
			}
		}
	}
	return m, nil
}

func (m *model) updateInstallPM(msg tea.Msg) (tea.Model, tea.Cmd) {
	if key, ok := msg.(tea.KeyMsg); ok {
		switch key.String() {
		case "up", "k":
			if m.cursor > 0 {
				m.cursor--
			}
		case "down", "j":
			if m.cursor < len(m.pmChoices)-1 {
				m.cursor++
			}
		case "enter":
			m.selectedPM = m.cursor
			m.step = stepInstallChecking
		case "esc":
			m.step = stepMenu
			m.cursor = 0
		}
	}
	return m, nil
}

func (m *model) updateCheckbox(msg tea.Msg, choices []string, selected map[int]struct{}, nextStep, prevStep int) (tea.Model, tea.Cmd) {
	if key, ok := msg.(tea.KeyMsg); ok {
		switch key.String() {
		case "up", "k":
			if m.cursor > 0 {
				m.cursor--
			}
		case "down", "j":
			if m.cursor < len(choices)-1 {
				m.cursor++
			}
		case " ":
			if _, ok := selected[m.cursor]; ok {
				delete(selected, m.cursor)
			} else {
				selected[m.cursor] = struct{}{}
			}
		case "enter":
			m.step = nextStep
			if m.step == stepUninstalling {
				return m, tea.Batch(m.progress.SetPercent(0), tickCmd())
			}
			m.cursor = 0
		case "esc":
			m.step = prevStep
			m.cursor = 0
		}
	}
	return m, nil
}

// Views

func (m model) View() string {
	if m.width == 0 {
		return "Initializing OCD Installer..."
	}

	header := banner()
	var body string

	switch m.step {
	case stepMenu:
		body = m.menuView()
	case stepInstallPM:
		body = m.pmView()
	case stepInstallChecking:
		body = fmt.Sprintf("\n  %s Checking system for OpenChamber Desktop requirements...", m.spinner.View())
	case stepInstallAliases:
		body = m.checkboxView("Step 3: Select Aliases", m.aliasChoices, m.selectedAliases)
	case stepInstallShortcuts:
		body = m.checkboxView("Step 4: Shortcut Options", m.scChoices, m.selectedShortcuts)
	case stepInstallConfirm:
		body = "\n  Ready to install OpenChamber Desktop.\n\n  Press Enter to begin installation."
	case stepInstalling:
		body = fmt.Sprintf("\n  Installing OCD...\n\n  %s", m.progress.View())
	case stepInstallDone:
		body = successStyle.Render("\n  ✅ Installation Complete!") + "\n\n  Press Enter to return to menu."
	case stepUninstallConfirmText:
		body = "\n  Are you sure you want to uninstall OCD?\n  This will remove all configuration.\n\n  Type 'yes' to confirm:\n\n" + m.textInput.View()
	case stepUninstallOptions:
		body = m.checkboxView("Step 2: Uninstall Options", m.uninstOpts, m.selectedUninst)
	case stepUninstalling:
		body = fmt.Sprintf("\n  Removing components...\n\n  %s", m.progress.View())
	case stepUninstallDone:
		body = successStyle.Render("\n  🗑️  OpenChamber Desktop has been removed.") + "\n\n  Press Enter to return to menu."
	case stepSysInfo:
		body = m.sysInfoView()
	}

	help := faintStyle.Render("\n\n↑/↓: navigate • enter: select • q: back/quit")
	return docStyle.Render(header + body + help)
}

func banner() string {
	return titleStyle.Render(`
   ____                   _____ _                     _               
  / __ \                 / ____| |                   | |              
 | |  | |_ __   ___ _ __| |    | |__   __ _ _ __ ___ | |__   ___ _ __ 
 | |  | | '_ \ / _ \ '_ \ |    | '_ \ / _' | '_ ' _ \| '_ \ / _ \ '__|
 | |__| | |_) |  __/ | | | |____| | | | (_| | | | | | | |_) |  __/ |   
  \____/| .__/ \___|_| |_|\_____|_| |_|\__,_|_| |_| |_|_.__/ \___|_|   
        | |                                                            
        |_|  INSTALLER V1.0                                            
`)
}

func (m model) menuView() string {
	s := "Main Menu:\n\n"
	for i, choice := range m.menuChoices {
		cursor := " "
		if m.cursor == i {
			cursor = ">"
			s += selectedStyle.Render(fmt.Sprintf("%s %s", cursor, choice)) + "\n"
		} else {
			s += fmt.Sprintf("%s %s", cursor, choice) + "\n"
		}
	}
	return s
}

func (m model) pmView() string {
	s := "Step 1: Select Package Manager\n\n"
	for i, choice := range m.pmChoices {
		cursor := " "
		if m.cursor == i {
			cursor = ">"
			s += selectedStyle.Render(fmt.Sprintf("%s [x] %s", cursor, choice)) + "\n"
		} else {
			s += fmt.Sprintf("%s [ ] %s", cursor, choice) + "\n"
		}
	}
	return s
}

func (m model) checkboxView(title string, choices []string, selected map[int]struct{}) string {
	s := title + ":\n\n"
	for i, choice := range choices {
		cursor := " "
		if m.cursor == i {
			cursor = ">"
		}
		checked := " "
		if _, ok := selected[i]; ok {
			checked = "x"
		}
		line := fmt.Sprintf("%s [%s] %s", cursor, checked, choice)
		if m.cursor == i {
			s += selectedStyle.Render(line) + "\n"
		} else {
			s += line + "\n"
		}
	}
	s += "\n  (Space: toggle • Enter: continue • Esc: back)"
	return s
}

func (m model) sysInfoView() string {
	pm := "Auto-detecting..."
	for _, p := range []string{"bun", "pnpm", "npm"} {
		if _, err := exec.LookPath(p); err == nil {
			pm = p
			break
		}
	}
	
	s := headerStyle.Render(" SYSTEM INFORMATION ") + "\n\n"
	s += fmt.Sprintf("  OS:         %s\n", runtime.GOOS)
	s += fmt.Sprintf("  Arch:       %s\n", runtime.GOARCH)
	s += fmt.Sprintf("  Package:    %s\n", pm)
	s += fmt.Sprintf("  Go Version: %s\n", runtime.Version())
	s += fmt.Sprintf("  Date:       %s\n", time.Now().Format("2006-01-02"))
	
	s += "\n  Press Enter or Esc to return."
	return s
}

func main() {
	p := tea.NewProgram(initialModel(), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Error: %v", err)
		os.Exit(1)
	}
}
